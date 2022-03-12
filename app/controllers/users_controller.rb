class UsersController < ApplicationController
  before_action :set_user, only: %i[show]

  def new; end

  def create
    @money = Money.find_by(name: params[:name], yen: params[:yen])
    if @money && @money == user_last_money
      @user = User.find(@money.user_id)
      redirect_to user_path(@user)
    else
      flash[:alert] = '検索に失敗しました。'
      redirect_to new_user_path
    end
  end

  def show; end

  def set_user
    @user = User.find(params[:id])
  end

  def user_last_money
    User.find(@money.user_id).moneys.last if @money
  end
end
