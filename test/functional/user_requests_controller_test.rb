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

  test 'should not update on weights step with wrong weights' do
    put :update, {:id => @user_request.id, :super_usage_weight_1 => 102}, {:user_request_step => "weights"}
    assert_redirected_to edit_user_request_path
    assert_equal I18n.t(:weights_step_wrong_choices), flash[:error]

    put :update, {:id => @user_request.id, :super_usage_weight_1 => -2}, {:user_request_step => "weights"}
    assert_redirected_to edit_user_request_path, 'no redirection'
    assert_equal I18n.t(:weights_step_wrong_choices), flash[:error]
  end

  test 'should not update on weights step with no weights' do
    put :update, {:id => @user_request.id}, {:user_request_step => "weights"}
    assert_redirected_to edit_user_request_path, 'no redirection'
    assert_equal I18n.t(:weights_step_no_choices), flash[:error]
  end

  test 'should update on weights step' do
    put :update, {:id => @user_request.id, :super_usage_weight_1 => 42}, {:user_request_step => "weights"}
    assert_redirected_to edit_user_request_path, 'no redirection'
    assert_nil flash[:error], "unexpected error flash"
  end

  test 'should not update on mobilities step with wrong weights' do
    mobility_choice = usage_choices(:mobilite_deplacement_choice)
    mobility_choice_id = mobility_choice.id
    mobility_choice_sym = "mobility_weight_#{mobility_choice_id}".to_sym
    put :update, {:id => @user_request.id, mobility_choice_sym => 102}, {:user_request_step => "mobilities"}
    assert_redirected_to edit_user_request_path
    assert_equal I18n.t(:mobilities_step_wrong_choices), flash[:error]

    put :update, {:id => @user_request.id, mobility_choice_sym => -2}, {:user_request_step => "mobilities"}
    assert_redirected_to edit_user_request_path, 'no redirection'
    assert_equal I18n.t(:mobilities_step_wrong_choices), flash[:error]
  end

  test 'should update on mobilities step' do
    mobility_choice = usage_choices(:mobilite_deplacement_choice)
    mobility_choice_id = mobility_choice.id
    mobility_choice_sym = "mobility_weight_#{mobility_choice_id}".to_sym
    put :update, {:id => @user_request.id, mobility_choice_sym => 42}, {:user_request_step => "mobilities"}
    assert_redirected_to user_response_user_request_path, 'bad redirection'
    assert_nil flash[:error], "unexpected error flash"
  end

  test 'should go to user_response page' do
    mobility_choice = usage_choices(:mobilite_deplacement_choice)
    mobility_choice_id = mobility_choice.id
    mobility_choice_str = "mobility_weight_#{mobility_choice_id}".to_str
    params = {mobility_choice_str => 12, :id => @user_request.to_param}
    user_response = @user_request.submit_and_get_response params
    get :user_response, params, {:user_response => user_response}
    assert_response :success, 'unsuccessful response'
    assert_template 'user_response'
  end

  test 'should go to home when no session' do
    get :user_response, :id => @user_request.to_param
    assert_redirected_to :root
  end
end
