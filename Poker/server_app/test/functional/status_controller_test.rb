require 'test_helper'

class StatusControllerTest < ActionController::TestCase
  test "should get action" do
    get :action
    assert_response :success
  end

end
