require 'test_helper'

class UserRequestTest < ActiveSupport::TestCase
  fixtures :user_requests
  
  test "should be valid" do
    assert user_requests(:valid).valid?
  end
  
  test "should have a valid order by" do
    assert user_requests(:invalid_order_by).invalid?
  end
  
  test "should have a positive num_result" do
    assert user_requests(:invalid_num_result).invalid?
  end
  
  test "should have a positive start_index" do
    assert user_requests(:invalid_start_index).invalid?
  end
end
