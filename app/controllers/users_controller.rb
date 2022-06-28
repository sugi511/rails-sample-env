class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy otp ]

  # GET /users or /users.json
  def index
    @users = if current_company
      current_company.users.all
    else
      User.all
    end
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    @user.otp_secret = ROTP::Base32.random_base32
  end

  # GET /users/1/edit
  def edit
    @user.otp_secret = ROTP::Base32.random_base32 if @user.otp_secret.blank?
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_url, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def otp
    @rotp = ROTP::TOTP.new(@user.otp_secret, issuer: "SENRI Ltd.")
    uri = @rotp.provisioning_uri("nori.setalab@google.com")
    @qrcode = RQRCode::QRCode.new(uri).as_svg(
      viewbox: true
    )
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.fetch(:user, {}).permit(:company_id, :name, :api_key, :api_secret, :otp_secret)
    end
end
