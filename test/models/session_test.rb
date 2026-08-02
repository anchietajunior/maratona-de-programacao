require "test_helper"

class SessionTest < ActiveSupport::TestCase
  setup { @session = users(:turing).sessions.create! }

  test "a new session starts active" do
    assert Session.active.exists?(@session.id)
  end

  test "a session leaves the active scope after the inactivity limit" do
    expire @session

    assert_not Session.active.exists?(@session.id)
  end

  test "touch_activity brings an expired session back" do
    expire @session

    @session.touch_activity

    assert Session.active.exists?(@session.id)
  end

  private
    #: (Session) -> void
    def expire(session)
      session.update_column :last_active_at, Session::INACTIVITY_LIMIT.ago - 1.second
    end
end
