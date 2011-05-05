require 'test_helper'

class UsageChoiceTest < ActiveSupport::TestCase
  fixtures :usage_choices
  def setup
    @usage_choice = usage_choices(:bureautique_simple_choice).clone 
  end
  
  def teardown
    @usage_choice = nil
  end
  
  test "should be valid" do
    assert @usage_choice.valid?
  end
  
  test "should have a weight_for_user" do
    @usage_choice.weight_for_user=nil
    assert @usage_choice.invalid?
  end
  
  test "should have a valid weight_for_user" do
    @usage_choice.weight_for_user=101
    assert @usage_choice.invalid?
    assert !@usage_choice.save
    @usage_choice.weight_for_user=39
    assert @usage_choice.valid?
  end
  
  test "should have a usage" do
    @usage_choice.usage=  nil
    assert @usage_choice.invalid?
    @usage_choice.usage=usages(:usage_1)
    assert @usage_choice.valid?
  end
  
  test "should have a valid usage" do
    @usage_choice.usage_id=-1
    assert @usage_choice.invalid?
    @usage_choice.usage_id=1
    assert @usage_choice.valid?
  end
  
  test "should have a user_request" do
    @usage_choice.user_request=nil
    assert @usage_choice.invalid?
    @usage_choice.user_request=user_requests(:test_request)
    assert @usage_choice.valid?
  end
  
  test "should have a valid user_request" do
    @usage_choice.user_request_id=0
    assert @usage_choice.invalid?
    @usage_choice.user_request=user_requests(:test_request)
    assert @usage_choice.valid?
  end
end
