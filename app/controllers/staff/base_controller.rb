class Staff::BaseController < ApplicationController
  before_action :ensure_staff

  private
    def ensure_staff
      head :forbidden unless Current.user.staff?
    end
end
