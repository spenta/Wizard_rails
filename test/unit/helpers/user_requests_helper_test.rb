require 'test_helper'

class UserRequestsHelperTest < ActionView::TestCase
  test 'should get important specs from gammas' do
    gammas_1 = {
    11 => 10,
    2 => 10,
    3 => 20,
    4 => 10,
    5 => 0,
    6 => 0,
    7 => 0,
    8 => 13,
    9 => 15,
    10 => 18,
    12 => 30,
    }
    result = get_important_specs_id_from(gammas_1)
    assert  result == [12, 3, 10, 9, 8], "result for gammas_1: #{result}"

    gammas_2 = {
    11 => 10,
    2 => 0,
    3 => 0,
    4 => 0,
    5 => 0,
    6 => 0,
    7 => 0,
    8 => 3,
    9 => 15,
    10 => 0,
    12 => 0,
    }

    result = get_important_specs_id_from(gammas_2)
    assert  result == [9, 11, 8, 5, 2], "result for gammas_2: #{result}"
  end

  test 'should give right color numbers' do
    assert_equal 0, get_color_number(0)
    assert_equal 1, get_color_number(0.3)
    assert_equal 1, get_color_number(0.5)
    assert_equal 2, get_color_number(0.6)
    assert_equal 3, get_color_number(0.75)
    assert_equal 4, get_color_number(0.83)
    assert_equal 5, get_color_number(1)
    assert_equal 6, get_color_number(1.2)
    assert_equal 7, get_color_number(1.5)
    assert_equal 8, get_color_number(1.8)
    assert_equal 9, get_color_number(3)
  end

end
