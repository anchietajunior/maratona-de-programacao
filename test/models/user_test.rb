require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips nickname" do
    user = User.new(nickname: "  EQUIPE07 ")
    assert_equal "equipe07", user.nickname
  end

  test "authenticates regardless of how the nickname was typed" do
    assert_equal users(:turing), User.authenticate_by(nickname: " Equipe01 ", password: "12345")
  end

  test "is not staff by default" do
    assert_not users(:turing).staff?
    assert users(:technical_committee).staff?
  end
end
