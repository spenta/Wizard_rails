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

  test 'should give right color numbers with relative score' do
    assert_equal 0, get_color_number_relative(0)
    assert_equal 1, get_color_number_relative(0.3)
    assert_equal 1, get_color_number_relative(0.5)
    assert_equal 2, get_color_number_relative(0.6)
    assert_equal 3, get_color_number_relative(0.75)
    assert_equal 4, get_color_number_relative(0.83)
    assert_equal 5, get_color_number_relative(1)
    assert_equal 6, get_color_number_relative(1.2)
    assert_equal 7, get_color_number_relative(1.5)
    assert_equal 8, get_color_number_relative(1.8)
    assert_equal 9, get_color_number_relative(3)
  end

  test 'should give right color numbers with absolute score' do
    assert_equal 0, get_color_number_absolute(-10)
    assert_equal 0, get_color_number_absolute(-9)
    assert_equal 0, get_color_number_absolute(-8)
    assert_equal 0, get_color_number_absolute(-7)
    assert_equal 0, get_color_number_absolute(-6.46)
    assert_equal 1, get_color_number_absolute(-6)
    assert_equal 1, get_color_number_absolute(-5)
    assert_equal 2, get_color_number_absolute(-4)
    assert_equal 2, get_color_number_absolute(-3)
    assert_equal 3, get_color_number_absolute(-2)
    assert_equal 4, get_color_number_absolute(-1)
    assert_equal 4, get_color_number_absolute(-0.54)
    assert_equal 5, get_color_number_absolute(0)
    assert_equal 6, get_color_number_absolute(1)
    assert_equal 7, get_color_number_absolute(2)
    assert_equal 7, get_color_number_absolute(3)
    assert_equal 8, get_color_number_absolute(4)
    assert_equal 8, get_color_number_absolute(5)
    assert_equal 8, get_color_number_absolute(5.4)
    assert_equal 8, get_color_number_absolute(6)
    assert_equal 8, get_color_number_absolute(6.9)
    assert_equal 9, get_color_number_absolute(7)
    assert_equal 9, get_color_number_absolute(8)
    assert_equal 9, get_color_number_absolute(9)
    assert_equal 9, get_color_number_absolute(10)
  end

end
