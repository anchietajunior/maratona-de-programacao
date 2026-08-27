class Staff::UsersController < Staff::BaseController
  before_action :set_user, only: %i[ edit update ]

  def index
    @users = User.competing.order(:nickname)
  end

  def edit
  end

  def update
    if @user.update user_params
      redirect_to staff_users_url, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.competing.find params[:id]
    end

    def user_params
      params.expect(user: [ :name, :password ])
    end
end
