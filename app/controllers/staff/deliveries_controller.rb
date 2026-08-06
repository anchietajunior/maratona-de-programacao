class Staff::DeliveriesController < Staff::BaseController
  def create
    Delivery.create! delivery_params
    redirect_to staff_balloons_url, notice: t(".created")
  end

  def destroy
    Delivery.find(params[:id]).destroy
    redirect_to staff_balloons_url, notice: t(".destroyed"), status: :see_other
  end

  private
    def delivery_params
      params.expect(delivery: [ :user_id, :problem_id ])
    end
end
