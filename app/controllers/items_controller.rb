class ItemsController < ApplicationController
  before_action :set_company
  before_action :set_item, only: %i[show edit update destroy]

  # GET /companies/:company_id/items or /companies/:company_id/items.json
  def index
    @items = @company.items

    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /companies/:company_id/items/1 or /companies/:company_id/items/1.json
  def show
    @vat_rates = @item.vat_rates
  end

  # GET /companies/:company_id/items/new
  def new
    @item = @company.items.new
  end

  # GET /companies/:company_id/items/1/edit
  def edit
  end

  # POST /companies/:company_id/items or /companies/:company_id/items.json
  def create
    @item = @company.items.new(item_params)

    respond_to do |format|
      if @item.save
        format.html { redirect_to company_items_path(@company), notice: "Item was successfully created." }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/:company_id/items/1 or /companies/:company_id/items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to company_items_path(@company), notice: "Item was successfully updated." }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/:company_id/items/1 or /companies/:company_id/items/1.json
  def destroy
    @item.destroy

    respond_to do |format|
      format.html { redirect_to company_items_path(@company), notice: "Item was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = @company.items.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def item_params
    params.require(:item).permit(:name)
  end
end
