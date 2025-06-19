class CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show edit update destroy sales_summary ]

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
      params.fetch(:company, {}).permit(:name)
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
      customers = @company.customers.includes(:region)
      sales_data = {}
      customer_totals = {}

      customers.each do |customer|
        sales_data[customer.id] = {}
        total = 0
        weeks.each do |week|
          # Generate random sales amount ($1,000 - $50,000)
          amount = rand(1_000..50_000)
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
end
