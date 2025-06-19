class CompaniesController < ApplicationController
  require 'openai'

  before_action :set_company, only: %i[ show edit update destroy sales_summary analyze_sales ]

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
  end

  # POST /companies/1/analyze_sales
  def analyze_sales
    user_message = params[:message]

    unless @company.openai_api_key.present?
      render json: { error: "OpenAI API keyが設定されていません。会社の設定でAPI keyを追加してください。" }, status: :unprocessable_entity
      return
    end

    begin
      # 売上データを取得
      sales_data = generate_sales_summary_data

      # テーブルデータをテキスト形式に変換
      table_data = format_sales_data_for_ai(sales_data)

      # OpenAI APIを呼び出し
      client = OpenAI::Client.new(access_token: @company.openai_api_key)
      p "以下の売上データを参考にして質問に答えてください：\n\n#{table_data}\n\n質問: #{user_message}"
      response = client.chat(
        parameters: {
          model: "gpt-4.1-nano",
          messages: [
            {
              role: "system",
              content: "あなたは売上データ分析の専門家です。提供された売上データを分析し、日本語で回答してください。"
            },
            {
              role: "user",
              content: "以下の売上データを参考にして質問に答えてください：\n\n#{table_data}\n\n質問: #{user_message}"
            }
          ],
          max_tokens: 1000,
          temperature: 0.7
        }
      )

      ai_response = response.dig("choices", 0, "message", "content")
      render json: { response: ai_response }

    rescue => e
      Rails.logger.error "OpenAI API Error: #{e.message}"
      render json: { error: "AI分析中にエラーが発生しました: #{e.message}" }, status: :internal_server_error
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
end
