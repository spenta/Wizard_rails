require 'test_helper'

class UserRequestsControllerTest < ActionController::TestCase
  setup do
    @user_request = user_requests(:test_request)
  end

  test "should create user_request" do
    assert_difference('UserRequest.count') do
      post :create, :user_request => @user_request.attributes
    end

    assert_redirected_to edit_user_request_path(assigns(:user_request))
  end


  test "should get form_step1" do
    get :edit, :id => @user_request.to_param
    assert_response :success
  end

end
