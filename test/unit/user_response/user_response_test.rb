require 'test_helper'

class UserResponseTest < ActiveSupport::TestCase
  fixtures :user_requests, :usage_choices

  def setup
    @user_request = user_requests(:test_request)
    usage_choices.each { |uc| @user_request.usage_choices << uc }
    @director = UserResponseDirector.new
    @director.builder = UserResponseBuilder.new
    @director.builder.user_request = @user_request
  end

  def teardown
    @user_request = nil
    @director.builder = nil
  end

  test 'should process response' do
    #----------------------------
    #usage processing
    #----------------------------
    @director.builder.process_specification_needs!
    actual_specs_needs_for_mobilities = @director.builder.specification_needs_for_mobilities
    actual_specs_needs_for_usages = @director.builder.specification_needs_for_usages

    assert @user_request.usage_choices.size == 20, "#{@user_request.usage_choices.size} user_choices"
    assert actual_specs_needs_for_usages.size == 44, "#{actual_specs_needs_for_usages.size} specs for usages instead of 44"
    assert actual_specs_needs_for_mobilities.size == 44, "#{actual_specs_needs_for_mobilities.size} specs for mobilities instead of 44"

    #random pick of values from the file user_response_test.xslx
    bureautique_choice = nil
    @user_request.usage_choices.each { |uc| bureautique_choice = uc }

    internet_choice = nil
    @user_request.usage_choices.each { |uc| internet_choice = uc }

    multimedia_choice = nil
    @user_request.usage_choices.each { |uc| multimedia_choice = uc }
    assert_in_delta actual_specs_needs_for_usages[5][1][1], 12.5, 0.001
    assert_in_delta actual_specs_needs_for_usages[11][1][0], 6, 0.001
    assert_in_delta actual_specs_needs_for_usages[32][1][0], 0, 0.001

    assert_in_delta actual_specs_needs_for_usages[5][2][0], 3, 0.001
    assert_in_delta actual_specs_needs_for_usages[6][2][1], 15, 0.001
    assert_in_delta actual_specs_needs_for_usages[16][2][0], 0, 0.001

    assert_in_delta actual_specs_needs_for_usages[3][6][1], 16.66667, 0.001
    assert_in_delta actual_specs_needs_for_usages[13][6][0], 10, 0.001
    assert_in_delta actual_specs_needs_for_usages[39][6][0], 0, 0.001

    #----------------------------
    #sigmas processing
    #see user_response_test.xlsx and sigmas.csv
    #----------------------------
    expected_sigmas = {1 => 0,2 => 3.75,3 => 4,4 => 4,5 => 3,6 => 4.5,7 => 0,9 => 3.325,10 => 0,11 => 5,12 => 0,13 => 10,14 => 0,15 => 0,16 => 0,17 => 0,18 => 0,19 => 0,20 => 0,23 => 0,30 => 0,31 => 0,32 => 0,33 => 0,34 => 0,35 => 0,36 => 0,37 => 0,38 => 0,39 => 0,40 => 0,41 => 0,42 => 0,43 => 0,44 => 0,45 => 0,46 => 0,47 => 0,48 => 0,49 => 0,81 => 0,82 => 0,83 => 0,84 => 2.375}
    @director.builder.process_sigmas!
    @director.builder.sigmas.each do |spec_id, actual_sigma|
      assert_in_delta expected_sigmas[spec_id], actual_sigma, 0.001, "unexpected sigma for specification #{spec_id}"
    end

    #----------------------------
    #gammas processing
    #see user_response_test.xlsx and gammas.csv
    #----------------------------
    expected_gammas = {1 => 0,2 => 14.93902439,3 => 9.485094851,4 => 11.38211382,5 => 3.556910569,6 => 6.402439024,7 => 0,9 => 9.024390244,10 => 0,11 => 28.21815718,12 => 0,13 => 11.38211382,14 => 0,15 => 0,16 => 0,17 => 0,18 => 0,19 => 0,20 => 0,23 => 0,30 => 0,31 => 0,32 => 0,33 => 0,34 => 0,35 => 0,36 => 0,37 => 0,38 => 0,39 => 0,40 => 0,41 => 0,42 => 0,43 => 0,44 => 0,45 => 0,46 => 0,47 => 0,48 => 0,49 => 0,81 => 0,82 => 0,83 => 0,84 => 5.609756098}
    @director.builder.process_gammas!
    @director.builder.gammas.each do |spec_id, actual_gamma|
      assert_in_delta expected_gammas[spec_id], actual_gamma, 0.001, "unexpected gamma for specification #{spec_id}"
    end
    #----------------------------
    #pi and delta processing
    #see ProductGraded16.xlsx
    #----------------------------
    @director.builder.process_pi_and_delta!
    product_scored_16 = nil
    @director.builder.products_scored.each {|ps| product_scored_16 = ps if ps.product.id==16}
    assert_in_delta product_scored_16.delta, 151.0812, 0.001
    assert_in_delta product_scored_16.pi, -9.17363, 0.001
    #----------------------------
    #spenta_score processing
    #see ProductGraded16.xlsx
    #----------------------------
    @director.builder.process_scores!
    #products_scored with delta <= delta_ok
    product_scored_16 = nil
    @director.builder.products_scored.each {|ps| product_scored_16 = ps if ps.product.id==16}
    assert_in_delta product_scored_16.spenta_score, 77.3998, 0.01
    #products_scored with delta > delta_ok
    product_scored_218 = nil
    @director.builder.products_scored.each {|ps| product_scored_218 = ps if ps.product.id==218}
    assert_in_delta product_scored_218.spenta_score, 104.71, 0.01
  end





end

