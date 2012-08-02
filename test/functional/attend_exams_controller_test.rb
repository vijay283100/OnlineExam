require 'test_helper'

class AttendExamsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
