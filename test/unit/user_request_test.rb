require 'test_helper'

class UserRequestTest < ActiveSupport::TestCase
  fixtures :user_requests
  def setup
    @user_request = user_requests(:test_request).clone
  end

  def teardown
    @user_request = nil
  end

  test "should be valid" do
    assert user_requests(:test_request).valid?
  end

end

