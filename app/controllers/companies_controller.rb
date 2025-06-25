class CompaniesController < ApplicationController
  require 'openai'

  before_action :set_company, only: %i[ show edit update destroy sales_summary analyze_sales estimate_tokens ]

  # GET /companies or /companies.json
  def index
    @companies = Company.all
  end

  # GET /companies/1 or /companies/1.json
  def show
  end

  # GET /companies/1/sales_summary
  def sales_summary
    @sales_data = generate_sales_summary_data
    @customers = @sales_data[:customers_sorted]

    # ページリロード時にスレッドの初期化フラグをリセット
    # これにより次回のAI分析時に最新の売上データが送信される
    session[:thread_initialized] = nil
  end

  # POST /companies/1/estimate_tokens
  def estimate_tokens
    user_message = params[:message]

    unless @company.openai_api_key.present?
      render json: { error: "OpenAI API keyが設定されていません。会社の設定でAPI keyを追加してください。" }, status: :unprocessable_entity
      return
    end

    begin
      # 会社ごとのスレッドIDを確認
      session_key = "openai_thread_#{@company.id}"
      thread_id = session[session_key]

      # 初回かどうかを判定
      is_first_message = session[:thread_initialized] != thread_id || thread_id.nil?

      if is_first_message
        # 初回の場合：売上データを含めて計算
        sales_data = generate_sales_summary_data
        table_data = format_sales_data_for_ai(sales_data)

        system_message = "あなたは#{@company.name}の売上データ分析の専門家です。"
        user_content = "以下は#{@company.name}の売上データです：\n\n#{table_data}\n\n質問: #{user_message}"

        estimated_tokens = calculate_estimated_tokens(system_message, user_content)
        message_type = "初回（売上データ含む）"
      else
        # 2回目以降：質問のみで計算
        system_message = ""
        user_content = user_message

        estimated_tokens = calculate_estimated_tokens(system_message, user_content)
        message_type = "継続（質問のみ）"
      end

      # 概算コストを計算（GPT-4の料金を基準）
      input_cost_per_1k = 0.03  # $0.03 per 1K tokens for GPT-4
      estimated_cost = (estimated_tokens / 1000.0) * input_cost_per_1k

      render json: {
        estimated_tokens: estimated_tokens,
        estimated_cost: estimated_cost.round(4),
        message_type: message_type,
        message_preview: user_content.length > 200 ? "#{user_content[0..200]}..." : user_content
      }

    rescue => e
      Rails.logger.error "Token estimation error: #{e.message}"
      render json: { error: "トークン数の計算中にエラーが発生しました: #{e.message}" }, status: :internal_server_error
    end
  end

  # POST /companies/1/analyze_sales
  def analyze_sales
    user_message = params[:message]

    unless @company.openai_api_key.present?
      render json: { error: "OpenAI API keyが設定されていません。会社の設定でAPI keyを追加してください。" }, status: :unprocessable_entity
      return
    end

    begin
      client = OpenAI::Client.new(access_token: @company.openai_api_key)

      # 初回かどうかを判定（セッションで管理）
      session_key = "thread_initialized_#{@company.id}"
      is_first_message = !session[session_key]

      if is_first_message
        # 初回の場合：売上データを含めて送信
        sales_data = generate_sales_summary_data
        table_data = format_sales_data_for_ai(sales_data)

        system_message = "あなたは#{@company.name}の売上データ分析の専門家です。提供された売上データを分析し、日本語で回答してください。"
        user_content = "以下は#{@company.name}の売上データです：\n\n#{table_data}\n\n質問: #{user_message}"

        # 初回フラグを設定
        session[session_key] = true
      else
        # 2回目以降：質問のみを送信
        system_message = "あなたは#{@company.name}の売上データ分析の専門家です。前回提供された売上データを基に、日本語で回答してください。"
        user_content = user_message
      end

      # リトライ機能付きでChat APIを呼び出し
      ai_response = call_openai_with_retry(client, system_message, user_content)
      render json: { response: ai_response }

    rescue => e
      Rails.logger.error "OpenAI API Error: #{e.message}"

      # エラーの種類に応じて適切なメッセージを返す
      error_message = case e.message
      when /429/
        "現在OpenAI APIの使用量制限に達しています。しばらく時間をおいてから再度お試しください。"
      when /401/
        "OpenAI APIキーが無効です。会社設定でAPIキーを確認してください。"
      when /404/
        "指定されたモデルが利用できません。APIキーの権限を確認してください。"
      else
        "AI分析中にエラーが発生しました。しばらく時間をおいてから再度お試しください。"
      end

      render json: { error: error_message }, status: :internal_server_error
    end
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies or /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        format.html { redirect_to companies_url, notice: "Company was successfully created." }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to companies_url, notice: "Company was successfully updated." }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1 or /companies/1.json
  def destroy
    @company.destroy

    respond_to do |format|
      format.html { redirect_to companies_url, notice: "Company was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.fetch(:company, {}).permit(:name, :openai_api_key)
    end

    # Generate sample sales summary data for Customer x Day table
    def generate_sales_summary_data
      # Get last month's date range
      last_month = 1.month.ago
      start_date = last_month.beginning_of_month
      end_date = last_month.end_of_month

      # Generate weekly date ranges
      weeks = []
      current_date = start_date.beginning_of_week

      while current_date <= end_date
        week_end = [current_date.end_of_week, end_date].min
        weeks << {
          start_date: current_date,
          end_date: week_end,
          label: "#{current_date.strftime('%m/%d')} - #{week_end.strftime('%m/%d')}"
        }
        current_date = current_date.next_week
      end

      # Generate sample sales data
      customers = @company.customers.includes(:region).limit(100)
      sales_data = {}
      customer_totals = {}

      customers.each do |customer|
        sales_data[customer.id] = {}
        total = 0
        weeks.each do |week|
          # Generate deterministic sales amount using customer.id and week start_date as seed
          # This ensures the same customer and same week always generate the same amount
          seed = "#{customer.id}_#{week[:start_date].strftime('%Y%m%d')}".hash.abs
          rng = Random.new(seed)
          amount = rng.rand(1_000..50_000)
          sales_data[customer.id][week[:label]] = amount
          total += amount
        end
        customer_totals[customer.id] = total
      end

      # Sort customers by total sales (highest first)
      customers_sorted = customers.sort_by { |customer| -customer_totals[customer.id] }

      {
        weeks: weeks,
        sales: sales_data,
        customers_sorted: customers_sorted
      }
    end

    # Format sales data for AI analysis
    def format_sales_data_for_ai(sales_data)
      output = "#{@company.name}の売上サマリー（先月分）\n\n"

      # ヘッダー行
      header = "顧客名\t地域\t"
      sales_data[:weeks].each { |week| header += "#{week[:label]}\t" }
      header += "合計"
      output += header + "\n"

      # データ行
      grand_total = 0
      sales_data[:customers_sorted].each do |customer|
        row = "#{customer.name}\t#{customer.region&.name || '未設定'}\t"
        customer_total = 0

        sales_data[:weeks].each do |week|
          amount = sales_data[:sales][customer.id][week[:label]]
          customer_total += amount
          row += "$#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}\t"
        end

        grand_total += customer_total
        row += "$#{customer_total.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
        output += row + "\n"
      end

      # 合計行
      total_row = "合計\t\t"
      sales_data[:weeks].each do |week|
        week_total = sales_data[:customers_sorted].sum { |c| sales_data[:sales][c.id][week[:label]] }
        total_row += "$#{week_total.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}\t"
      end
      total_row += "$#{grand_total.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
      output += total_row + "\n"

      output
    end

    # Calculate estimated tokens for the given messages
    def calculate_estimated_tokens(system_message, user_content)
      # 簡易的なトークン数計算
      # 日本語文字は約1.5トークン、英数字は約0.75トークンとして計算

      total_chars = system_message.length + user_content.length

      # 日本語文字数をカウント（ひらがな、カタカナ、漢字）
      japanese_chars = (system_message + user_content).scan(/[\p{Hiragana}\p{Katakana}\p{Han}]/).length

      # 英数字・記号文字数
      other_chars = total_chars - japanese_chars

      # 概算トークン数計算
      estimated_tokens = (japanese_chars * 1.5) + (other_chars * 0.75)

      # 最低でも文字数の半分はトークンとして計算
      [estimated_tokens, total_chars * 0.5].max.to_i
    end

    # リトライ機能付きでOpenAI APIを呼び出し
    def call_openai_with_retry(client, system_message, user_content, max_retries = 3)
      retries = 0

      begin
        response = client.chat(
          parameters: {
            model: "gpt-3.5-turbo",
            messages: [
              {
                role: "system",
                content: system_message
              },
              {
                role: "user",
                content: user_content
              }
            ],
            max_tokens: 1000,
            temperature: 0.7
          }
        )

        return response.dig("choices", 0, "message", "content")

      rescue => e
        retries += 1

        # 429エラー（レート制限）の場合はリトライ
        if e.message.include?("429") && retries <= max_retries
          wait_time = 2 ** retries  # 指数バックオフ: 2秒、4秒、8秒
          Rails.logger.warn "OpenAI API rate limit hit. Retrying in #{wait_time} seconds... (attempt #{retries}/#{max_retries})"
          sleep(wait_time)
          retry
        else
          # その他のエラーまたは最大リトライ回数に達した場合は例外を再発生
          raise e
        end
      end
    end

    # 会社ごとのスレッドIDを取得または作成
    def get_or_create_thread_for_company(client)
      session_key = "openai_thread_#{@company.id}"
      thread_id = session[session_key]

      # スレッドが存在しない、または無効な場合は新規作成
      if thread_id.nil? || !thread_exists?(client, thread_id)
        thread = client.threads.create
        thread_id = thread["id"]
        session[session_key] = thread_id
        # 新しいスレッドなので初期化フラグをリセット
        session[:thread_initialized] = nil
      end

      thread_id
    end

    # スレッドが存在するかチェック
    def thread_exists?(client, thread_id)
      client.threads.retrieve(id: thread_id)
      true
    rescue
      false
    end

    # アシスタントを取得または作成
    def get_or_create_assistant(client)
      # 会社ごとのアシスタントIDをセッションで管理
      session_key = "openai_assistant_#{@company.id}"
      assistant_id = session[session_key]

      # アシスタントが存在しない、または無効な場合は新規作成
      if assistant_id.nil? || !assistant_exists?(client, assistant_id)
        assistant = client.assistants.create(
          parameters: {
            name: "#{@company.name} 売上分析アシスタント",
            instructions: "あなたは#{@company.name}の売上データ分析の専門家です。提供された売上データを分析し、日本語で分かりやすく回答してください。データの傾向、パターン、改善提案などを含めて回答してください。",
            model: "gpt-4-1106-preview"
          }
        )
        assistant_id = assistant["id"]
        session[session_key] = assistant_id
      end

      assistant_id
    end

    # アシスタントが存在するかチェック
    def assistant_exists?(client, assistant_id)
      client.assistants.retrieve(id: assistant_id)
      true
    rescue
      false
    end

    # 実行完了を待機
    def wait_for_run_completion(client, thread_id, run_id, max_wait_time = 30)
      start_time = Time.current

      loop do
        run = client.runs.retrieve(thread_id: thread_id, id: run_id)
        status = run["status"]

        return status if ["completed", "failed", "cancelled", "expired"].include?(status)

        # タイムアウトチェック
        if Time.current - start_time > max_wait_time
          return "timeout"
        end

        sleep(1)
      end
    end

end
