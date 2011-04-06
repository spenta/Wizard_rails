require 'test_helper'

class UserRequestTest < ActiveSupport::TestCase
  fixtures :user_requests
  def setup
    @user_request = user_requests(:gamer).clone 
  end
  
  def teardown
    @user_request = nil
  end
  
  test "should be valid" do
    assert user_requests(:gamer).valid?
  end
  
  test "should have a valid order by" do
    @user_request.order_by="invalid string"
    assert @user_request.invalid?
    @user_request.order_by="spenta_score"
    assert @user_request.valid?
  end
  
  test "should have a positive num_result" do
    @user_request.num_result=-1
    assert @user_request.invalid?
    @user_request.num_result=10
    assert @user_request.valid?
  end
  
  test "should have a positive start_index" do
    @user_request.start_index=-1
    assert @user_request.invalid?
    @user_request.start_index=10
    assert @user_request.valid?
  end
end
