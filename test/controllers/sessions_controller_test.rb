require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:turing) }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials lands a team on its scoreboard" do
    post session_path, params: { nickname: @user.nickname, password: "12345" }

    assert_redirected_to scoreboard_path
    assert cookies[:session_id]
  end

  test "create lands staff on the staff surface" do
    committee = users(:technical_committee)

    post session_path, params: { nickname: committee.nickname, password: "12345" }

    assert_redirected_to staff_root_path
  end

  test "create honours the page the user was reaching for" do
    get scoreboard_path

    post session_path, params: { nickname: @user.nickname, password: "12345" }

    assert_redirected_to scoreboard_url
  end

  test "create with invalid credentials" do
    post session_path, params: { nickname: @user.nickname, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as @user

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  test "a second machine cannot sign in while the team's session is active" do
    @user.sessions.create!

    assert_no_difference -> { @user.sessions.count } do
      post session_path, params: { nickname: @user.nickname, password: "12345" }
    end

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "an inactive session frees the team to sign in again" do
    @user.sessions.create!.update_column :last_active_at, Session::INACTIVITY_LIMIT.ago - 1.second

    assert_difference -> { @user.sessions.count }, +1 do
      post session_path, params: { nickname: @user.nickname, password: "12345" }
    end

    assert_redirected_to scoreboard_path
  end

  test "staff signs in from a second machine" do
    committee = users(:technical_committee)
    committee.sessions.create!

    assert_difference -> { committee.sessions.count }, +1 do
      post session_path, params: { nickname: committee.nickname, password: "12345" }
    end

    assert_redirected_to staff_root_path
  end

  test "an inactive session still authenticates the browser that owns it" do
    sign_in_as @user
    @user.sessions.sole.update_column :last_active_at, Session::INACTIVITY_LIMIT.ago - 1.second

    assert_difference -> { @user.sessions.count }, -1 do
      delete session_path
    end
  end
end
