require 'test_helper'

class UserRequestsControllerTest < ActionController::TestCase
  setup do
    @user_request = user_requests(:test_request)
  end

  test "should create user_request" do
    assert_difference('UserRequest.count') do
      post :create, :user_request => @user_request.attributes
    end

    assert_redirected_to form_step1_user_request_path(assigns(:user_request))
  end


  test "should get form_step1" do
    get :form_step1, :id => @user_request.to_param
    assert_response :success
  end

  test "should update user_request" do
    put :update, :id => @user_request.to_param, :user_request => @user_request.attributes, :usage_choice_selected_1 => 1, :super_usage_choice_1 => 20
    assert_redirected_to user_response_user_request_path(assigns(:user_request))
  end
end
