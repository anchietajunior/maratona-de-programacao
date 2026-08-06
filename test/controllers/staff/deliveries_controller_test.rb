require "test_helper"

class Staff::DeliveriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:technical_committee) }

  test "the balloon screen lists a balloon for each solved problem" do
    get staff_balloons_path

    assert_response :success
    assert_select "h2", text: "Turing"
    assert_select "h2", { text: "Lovelace", count: 0 }
  end

  test "delivering a balloon records who delivered it" do
    assert_difference -> { Delivery.count }, +1 do
      post staff_deliveries_path,
        params: { delivery: { user_id: users(:turing).id, problem_id: problems(:easy_sum).id } }
    end

    assert_equal users(:technical_committee), Delivery.last.staff
    assert_redirected_to staff_balloons_path
  end

  test "a delivery can be undone" do
    delivery = Delivery.create! user: users(:turing), problem: problems(:easy_sum), staff: users(:technical_committee)

    assert_difference -> { Delivery.count }, -1 do
      delete staff_delivery_path(delivery)
    end
  end

  test "the same balloon is never delivered twice" do
    Delivery.create! user: users(:turing), problem: problems(:easy_sum), staff: users(:technical_committee)
    duplicate = Delivery.new user: users(:turing), problem: problems(:easy_sum), staff: users(:technical_committee)

    assert_not duplicate.valid?
  end
end
