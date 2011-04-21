require 'test_helper'

class UserRequestsHelperTest < ActionView::TestCase
  test 'should get important specs from gammas' do
    gammas_1 = {
    1 => 10,
    2 => 10,
    3 => 20,
    4 => 10,
    5 => 0,
    6 => 0,
    7 => 0,
    8 => 13,
    9 => 15,
    10 => 18,
    11 => 30,
    }
    result = get_important_specs_id_from(gammas_1)
    assert  result == [11, 3, 10, 9, 8], "result for gammas_1: #{result}"

    gammas_2 = {
    1 => 10,
    2 => 0,
    3 => 0,
    4 => 0,
    5 => 0,
    6 => 0,
    7 => 0,
    8 => 3,
    9 => 15,
    10 => 0,
    11 => 0,
    }

    result = get_important_specs_id_from(gammas_2)
    assert  result == [9, 1, 8, 5, 2], "result for gammas_2: #{result}"
  end
end
