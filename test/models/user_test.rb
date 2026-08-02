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

  test "a team with an active session is signed in elsewhere" do
    turing = users(:turing)
    turing.sessions.create!

    assert turing.signed_in_elsewhere?
  end

  test "a team whose session went inactive is not signed in elsewhere" do
    turing = users(:turing)
    turing.sessions.create!.update_column :last_active_at, Session::INACTIVITY_LIMIT.ago - 1.second

    assert_not turing.signed_in_elsewhere?
  end

  test "staff is never signed in elsewhere, however many sessions it has" do
    committee = users(:technical_committee)
    committee.sessions.create!

    assert_not committee.signed_in_elsewhere?
  end
end
