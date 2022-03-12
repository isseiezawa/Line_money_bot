class UsersController < ApplicationController
  before_action :set_user, only: %i[show]

  def new; end

  def create
    money = Money.find_by(name: params[:name], yen: params[:yen])
    if money
      binding.pry
      @user = User.find(money.user_id)
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def show; end

  def set_user
    @user = User.find(params[:id])
  end
end
