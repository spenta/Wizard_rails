require 'test_helper'

class UserRequestsControllerTest < ActionController::TestCase
  setup do
    @user_request = user_requests(:test_request)
  end

  test "should create user_request" do
    assert_difference('UserRequest.count') do
      post :create
    end
  
    new_user_request = UserRequest.last
    assert_equal new_user_request.usage_choices.size, Usage.count
    new_user_request.usage_choices.all do |uc|
     assert_equal(uc.weight_for_user, 0) if uc.usage.super_usage.name == "Mobilite" 
     assert_equal(uc.weight_for_user, 50) unless uc.usage.super_usage.name == "Mobilite" 
    end

    assert_redirected_to edit_user_request_path(assigns(:user_request))
  end


  test "should get form_step1" do
    get :edit, :id => @user_request.to_param
    assert_response :success
  end

end
