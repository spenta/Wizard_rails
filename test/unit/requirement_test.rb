require 'test_helper'

class RequirementTest < ActiveSupport::TestCase
  fixtures :requirements 
  setup do
    @requirement = requirements(:requirement_1).clone
  end
  
  def teardown
    @requirement = nil
  end
  
  test "requirement should be valid" do
    assert @requirement.valid?
  end
  
  test "requirement should have a target_score" do
    @requirement.target_score=nil
    assert @requirement.invalid?
    @requirement.target_score=4.8
    assert @requirement.valid?
  end
  
  test "requirement should have a valid target_score" do
    @requirement.target_score=11
    assert @requirement.invalid?
    @requirement.target_score=0
    assert @requirement.valid?
  end
  
  test "requirement should have a weight" do
    @requirement.weight=nil
    assert @requirement.invalid?
    @requirement.weight=45
    assert @requirement.valid?
  end
  
  test "requirement should have a valid weight" do
    @requirement.weight=-2
    assert @requirement.invalid?
    @requirement.weight=34
    assert @requirement.valid?
  end
  
  test "requirement should have a specification_id" do
    @requirement.specification=nil
    assert @requirement.invalid?
    @requirement.specification=specifications(:specification_1)
    assert @requirement.valid?
  end
  
  test "requirement should have a usage" do
    @requirement.usage=nil
    assert @requirement.invalid?
    @requirement.usage_id=1
    assert @requirement.valid?
  end
  
  test "requirement should have a valid usage" do
    @requirement.usage_id=-1
    assert @requirement.invalid?
    @requirement.usage_id=1
    assert @requirement.valid?
  end
end
