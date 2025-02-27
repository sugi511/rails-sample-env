class TransactionsController < ApplicationController
  before_action :set_company
  before_action :set_transaction, only: %i[show edit update destroy]

  # GET /companies/:company_id/transactions or /companies/:company_id/transactions.json
  def index
    @transactions = @company.transactions
  end

  # GET /companies/:company_id/transactions/1 or /companies/:company_id/transactions/1.json
  def show
    @deals = @transaction.deals
  end

  # GET /companies/:company_id/transactions/new
  def new
    @transaction = @company.transactions.build
  end

  # GET /companies/:company_id/transactions/1/edit
  def edit
  end

  # POST /companies/:company_id/transactions or /companies/:company_id/transactions.json
  def create
    @transaction = @company.transactions.build(transaction_params)

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to company_transaction_path(@company, @transaction), notice: "Transaction created successfully." }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/:company_id/transactions/1 or /companies/:company_id/transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to company_transaction_path(@company, @transaction), notice: "Transaction updated successfully." }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/:company_id/transactions/1 or /companies/:company_id/transactions/1.json
  def destroy
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to company_transactions_path(@company), notice: "Transaction deleted successfully." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_transaction
    @transaction = @company.transactions.find(params[:id])
  end
  
  # Only allow a list of trusted parameters through.
  def transaction_params
    params.require(:transaction).permit(:user_id, :customer_id, :transaction_date)
  end
end
