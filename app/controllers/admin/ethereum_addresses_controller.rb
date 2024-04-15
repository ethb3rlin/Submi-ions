class Admin::EthereumAddressesController < ApplicationController
  def create
    @user = User.find(params[:user_id])
    @ethereum_address = @user.ethereum_addresses.new(ethereum_address_params)
    authorize @ethereum_address
    if @ethereum_address.save
      redirect_to admin_user_path(@user), notice: "Address added"
    else
      redirect_to admin_user_path(@user), alert: "Failed to add an address: " + @ethereum_address.errors.full_messages.join(", ")
    end
  end

  def destroy
    @ethereum_address = EthereumAddress.find(params[:id])
    authorize @ethereum_address
    @ethereum_address.destroy
    redirect_to admin_user_path(@ethereum_address.user), notice: "Address #{@ethereum_address.address} removed"
  end

  private
  def ethereum_address_params
    params.require(:ethereum_address).permit(:address)
  end
end
