require 'test_helper'

class UsageTest < ActiveSupport::TestCase
  fixtures :usages, :super_usages
  setup do
    @usage = usages(:jeux_regulier)
    @super_usage = super_usages(:jeux)
  end
  
  test "should be valid" do
    assert @usage.valid?
  end
  
  test "should have a name" do
    usage_without_name = Usage.new
    assert usage_without_name.invalid?
  end

end
