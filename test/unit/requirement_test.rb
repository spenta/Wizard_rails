require 'test_helper'

class RequirementTest < ActiveSupport::TestCase
  fixtures :requirements 
  setup do
    @requirement = requirements(:requirement_1)
  end
  
  test "requirement should be valid" do
    assert @requirement.valid?
  end
  
  test "requirement should have a target_score" do
    requirement_without_target_score = Requirement.new(:weight => requirements(:requirement_1).weight,
                                :specification_id => requirements(:requirement_1).specification_id,
                                :usage => requirements(:requirement_1).usage)
    assert requirement_without_target_score.invalid?
  end
  
  test "requirement should have a valid target_score" do
    requirement_without_valid_target_score = Requirement.new(:target_score => 11, :weight => requirements(:requirement_1).weight,
                                :specification_id => requirements(:requirement_1).specification_id,
                                :usage => requirements(:requirement_1).usage)
    assert requirement_without_valid_target_score.invalid?
    requirement_without_valid_target_score.target_score = -1
    assert requirement_without_valid_target_score.invalid?
    requirement_without_valid_target_score.target_score = 3
    assert requirement_without_valid_target_score.valid?
  end
  
  test "requirement should have a weight" do
    requirement_without_weight = Requirement.new(:target_score => requirements(:requirement_1).target_score,
                                :specification_id => requirements(:requirement_1).specification_id,
                                :usage => requirements(:requirement_1).usage)
    assert requirement_without_weight.invalid?
  end
  
  test "requirement should have a valid weight" do
    requirement_without_valid_weight = Requirement.new(:target_score => requirements(:requirement_1).target_score, :weight => 100.01,
                                :specification_id => requirements(:requirement_1).specification_id,
                                :usage => requirements(:requirement_1).usage)
    assert requirement_without_valid_weight.invalid?
    requirement_without_valid_weight.weight = -0.1
    assert requirement_without_valid_weight.invalid?
    requirement_without_valid_weight.weight = 34.234
    assert requirement_without_valid_weight.valid?
  end
  
  test "requirement should have a specification_id" do
    requirement_without_specification = Requirement.new(:target_score => requirements(:requirement_1).target_score,
                                :weight => requirements(:requirement_1).weight,
                                :usage => requirements(:requirement_1).usage)
    assert requirement_without_specification.invalid?
  end
  
  test "requirement should have a usage" do
    requirement_without_usage = Requirement.new(:target_score => requirements(:requirement_1).target_score,
                                :weight => requirements(:requirement_1).weight,
                                :specification_id => requirements(:requirement_1).specification_id)
    assert requirement_without_usage.invalid?
  end
  
  test "requirement should have a valid usage" do
    requirement_without_valid_usage = Requirement.new(:target_score => requirements(:requirement_1).target_score,
                                :weight => requirements(:requirement_1).weight,
                                :specification_id => requirements(:requirement_1).specification_id,
                                :usage_id => 0)
    assert requirement_without_valid_usage.invalid?
  end
end
