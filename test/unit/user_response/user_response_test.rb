require './app/models/user_response/user_response'
require 'test_helper'

class UserResponseTest < ActiveSupport::TestCase
  fixtures :user_requests, :usage_choices

  def setup
    @user_request = user_requests(:test_request)
    usage_choices.each { |uc| @user_request.usage_choices << uc }
  end

  def teardown
    @user_request = nil
    @director.builder = nil
  end

  test 'should process all usages and all specs' do
    @director = UserResponseDirector.new
    @director.builder = UserResponseBuilder.new
    assert !@user_request.nil? , "@user_request is nil"
    assert @user_request.usage_choices.class == Array, "class is #{@user_request.class}"
    assert @user_request.usage_choices.size == 20, "usage_choices size is #{@user_request.usage_choices.size}"
    @director.builder.process_specification_needs! @user_request.usage_choices
    actual_response = @director.get_response
    actual_specs_needs_for_mobilities = actual_response.specification_needs_for_mobilities
    actual_specs_needs_for_usages = actual_response.specification_needs_for_usages

    assert @user_request.usage_choices.size == 20, "#{@user_request.usage_choices.size} user_choices"
    assert actual_specs_needs_for_usages.size == 44, "#{actual_specs_needs_for_usages.size} specs for usages instead of 44"
    assert actual_specs_needs_for_mobilities.size == 44, "#{actual_specs_needs_for_mobilities.size} specs for mobilities instead of 44"

    error_in_mobilities = false
    actual_specs_needs_for_mobilities.each do |spec_id, mobility_hash|
      mobility_hash.each do |mobility_id, values|
        mobility_choice = nil
        @user_request.usage_choices.each { |uc| mobility_choice = uc if uc.id = mobility_id }
        #checks beta
        error_in_mobilities = true unless values[2] = mobility_choice.weight_for_user
        requirement = Usage.find(mobility_id).requirements.where(:specification_id => spec_id ).first
        #checks U and alpha
        error_in_mobilities = true unless values[0] = requirement.target_score
        error_in_mobilities = true unless values[1] = requirement.weight
      end
    end
    assert !error_in_mobilities, "errors in specification_needs_for_mobilities"

    #random pick of values from the file user_response_test.xslx
    bureautique_choice = nil
    @user_request.usage_choices.each { |uc| bureautique_choice = uc }

    internet_choice = nil
    @user_request.usage_choices.each { |uc| internet_choice = uc }

    multimedia_choice = nil
    @user_request.usage_choices.each { |uc| multimedia_choice = uc }
    assert_in_delta actual_response.specification_needs_for_usages[5][0][1], 12.5, 0.001
    assert_in_delta actual_response.specification_needs_for_usages[11][0][0], 6, 0.001
    assert_in_delta actual_response.specification_needs_for_usages[32][0][0], 0, 0.001

    assert_in_delta actual_response.specification_needs_for_usages[5][1][0], 3, 0.001
    assert_in_delta actual_response.specification_needs_for_usages[6][1][1], 15, 0.001
    assert_in_delta actual_response.specification_needs_for_usages[16][1][0], 0, 0.001

    assert_in_delta actual_response.specification_needs_for_usages[3][5][1], 16.66667, 0.001
    assert_in_delta actual_response.specification_needs_for_usages[13][5][0], 10, 0.001
    assert_in_delta actual_response.specification_needs_for_usages[39][5][0], 0, 0.001

  end
end

