require 'test_helper'

class SpecificationTest < ActiveSupport::TestCase
  fixtures :specifications
  setup do
    @specification = specifications(:specification_1)
  end
  
  test "should be valid" do
    assert @specification.valid?
  end
  
  test "should have a name" do
    specification_without_name = Specification.new(:specification_type => "continuous")
    assert specification_without_name.invalid?
  end
  
  test "should have a type" do
    specification_without_type = Specification.new(:name => "nom")
    assert specification_without_type.invalid?
  end
  
  test "should have a valid type" do
    specification_without_valid_type = Specification.new(:name => "nom", :specification_type => "faux_type")
  end
end
