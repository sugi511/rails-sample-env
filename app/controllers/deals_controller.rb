class DealsController < ApplicationController
  before_action :set_sales_transaction
  before_action :set_deal, only: %i[edit update destroy]

  # GET /transactions/:transaction_id/deals/new
  def new
    @deal = @sales_transaction.deals.build
  end

  # GET /transactions/:transaction_id/deals/1/edit
  def edit
  end

  # POST /transactions/:transaction_id/deals
  def create
    @deal = @sales_transaction.deals.build(deal_params)

    respond_to do |format|
      if @deal.save
        format.html { redirect_to company_transaction_path(@sales_transaction.company, @sales_transaction), notice: "Deal added successfully." }
        format.json { render :show, status: :created, location: @deal }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transactions/:transaction_id/deals/1
  def update
    respond_to do |format|
      if @deal.update(deal_params)
        format.html { redirect_to company_transaction_path(@sales_transaction.company, @sales_transaction), notice: "Deal updated successfully." }
        format.json { render :show, status: :ok, location: @deal }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/:transaction_id/deals/1
  def destroy
    @deal.destroy
    respond_to do |format|
      format.html { redirect_to company_transaction_path(@sales_transaction.company, @sales_transaction), notice: "Deal removed successfully." }
      format.json { head :no_content }
    end
  end

  private
   # Use callbacks to share common setup or constraints between actions.
  def set_transaction
    @sales_transaction = Transaction.find(params[:transaction_id])
  end

  def set_deal
    @deal = @sales_transaction.deals.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def deal_params
    params.require(:deal).permit(:item_id, :price, :quantity, :vat_rate_id)
  end
end
