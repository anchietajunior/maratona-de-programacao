require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "show is reachable without authentication" do
    get root_path

    assert_response :success
    assert_select "a[href=?]", new_session_path
    assert_select "a[href=?]", "/regulamento.pdf"
  end
end
