require 'test_helper'

class UsageChoiceTest < ActiveSupport::TestCase
  fixtures :usage_choices
  
  test "should be valid" do
    assert usage_choices(:valid).valid?
  end
  
  test "should have a weight_for_user" do
    assert usage_choices(:no_weight).invalid?
  end
  
  test "should have a valid weight_for_user" do
    assert usage_choices(:invalid_weight).invalid?
  end
  
  test "should have a usage" do
    assert usage_choices(:no_usage).invalid?
  end
  
  test "should have a valid usage" do
    assert usage_choices(:invalid_usage).invalid?
  end
  
  test "should have a user_request" do
    assert usage_choices(:no_request).invalid?
  end
  
  test "should have a valid user_request" do
    assert usage_choices(:invalid_request).invalid?
  end
  
end
