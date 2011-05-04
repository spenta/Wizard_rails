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


  test "should get edit" do
    get :edit, :id => @user_request.to_param
    assert_response :success
  end

  test "should get back to previous step" do
    get :edit, {:id => @user_request.to_param, :back => "true"},{:user_request_step => "mobilities"}
    assert_response :success
    assert_equal "weights", session[:user_request_step] 
  end

  test 'should not update on selection step with no selection' do
    put :update, {:id => @user_request.id}, {:user_request_step => "selection"}
    assert_redirected_to edit_user_request_path
    assert_equal I18n.t(:no_usage_selected_error), flash[:error]
  end

  test 'should update on selection step' do
    bureautique_simple_choice_id = usage_choices(:bureautique_simple_choice).id
    UsageChoice.find(bureautique_simple_choice_id).update_attributes :is_selected => false
    bureautique_simple_choice_sym = "usage_choice_selected_#{bureautique_simple_choice_id}".to_sym
    put :update, {:id => @user_request.id, bureautique_simple_choice_sym => "true"}, {:user_request_step => "selection"}
    assert_redirected_to edit_user_request_path, "no redirection"
    assert_nil flash[:error], "unexpected error flash"
    assert UsageChoice.find(bureautique_simple_choice_id).is_selected, "usage choice should have been selected"
  end
end
