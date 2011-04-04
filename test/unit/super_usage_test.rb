require 'test_helper'

class SuperUsageTest < ActiveSupport::TestCase
  fixtures :usages, :super_usages
  setup do
    @usage = usages(:regulier)
    @super_usage = super_usages(:jeux)
  end
  
  test "should be valid" do
    assert @super_usage.valid?
  end
  
  test "should have a name" do
    superusage_without_name = SuperUsage.new
    assert superusage_without_name.invalid?
  end
end
