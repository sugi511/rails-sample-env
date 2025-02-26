class VatRatesController < ApplicationController
  before_action :set_item
  before_action :set_vat_rate, only: %i[show edit update destroy]

  # GET /companies/:company_id/items/:item_id/vat_rates or /companies/:company_id/items/:item_id/vat_rates.json
  def index
    @vat_rates = @item.vat_rates

    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /companies/:company_id/items/:item_id/vat_rates/1 or /companies/:company_id/items/:item_id/vat_rates/1.json
  def show
  end

  # GET /companies/:company_id/items/:item_id/vat_rates/new
  def new
    @vat_rate = @item.vat_rates.new
  end

  # GET /companies/:company_id/items/:item_id/vat_rates/1/edit
  def edit
  end

  # POST /companies/:company_id/items/:item_id/vat_rates or /companies/:company_id/items/:item_id/vat_rates.json
  def create
    @vat_rate = @item.vat_rates.new(vat_rate_params)

    respond_to do |format|
      if @vat_rate.save
        format.html { redirect_to company_item_vat_rates_path(@item.company, @item), notice: "VAT Rate successfully added." }
        format.json { render :show, status: :created, location: @vat_rate }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vat_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/:company_id/items/:item_id/vat_rates/1 or /companies/:company_id/items/:item_id/vat_rates/1.json
  def update
    respond_to do |format|
      if @vat_rate.update(vat_rate_params)
        format.html { redirect_to company_item_vat_rates_path(@item.company, @item), notice: "VAT Rate successfully updated." }
        format.json { render :show, status: :ok, location: @vat_rate }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @vat_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/:company_id/items/:item_id/vat_rates/1 or /companies/:company_id/items/:item_id/vat_rates/1.json
  def destroy
    @vat_rate.destroy

    respond_to do |format|
      format.html { redirect_to company_item_vat_rates_path(@item.company, @item), notice: "VAT Rate successfully deleted." }
      format.json { head :no_content }
    end
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_vat_rate
    @vat_rate = @item.vat_rates.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def vat_rate_params
    params.require(:vat_rate).permit(:rate)
  end
end
