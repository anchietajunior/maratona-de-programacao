require "test_helper"

class Staff::UsersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:technical_committee) }

  test "a team is forbidden from the team management" do
    sign_out
    sign_in_as users(:turing)

    get staff_users_path

    assert_response :forbidden
  end

  test "index lists the teams and never the staff" do
    get staff_users_path

    assert_response :success
    assert_select "li", text: /Turing/
    assert_select "li", text: /comissao/, count: 0
  end

  test "edit renders the form without exposing the current password" do
    get edit_staff_user_path(users(:turing))

    assert_response :success
    assert_select "input[name=?]", "user[name]"
    assert_select "input[name=?][value]", "user[password]", count: 0
  end

  test "staff updates a team's name and password" do
    patch staff_user_path(users(:turing)), params: { user: { name: "Alan Turing", password: "enigma" } }

    assert_redirected_to staff_users_path
    assert_equal "Alan Turing", users(:turing).reload.name
    assert users(:turing).authenticate("enigma")
  end

  test "a blank password keeps the current one" do
    patch staff_user_path(users(:turing)), params: { user: { name: "Turing", password: "" } }

    assert_redirected_to staff_users_path
    assert users(:turing).reload.authenticate("12345")
  end

  test "a blank name is rejected" do
    patch staff_user_path(users(:turing)), params: { user: { name: "", password: "" } }

    assert_response :unprocessable_entity
    assert_equal "Turing", users(:turing).reload.name
  end

  test "a staff user is out of reach even by id" do
    patch staff_user_path(users(:technical_committee)), params: { user: { name: "Hacked" } }

    assert_response :not_found
    assert_equal "Comissão Técnica", users(:technical_committee).reload.name
  end
end
