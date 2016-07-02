require 'test_helper'

class HelloControllerTest < ActionController::TestCase
  test "should get sayhello" do
    get :sayhello
    assert_response :success
  end

end
