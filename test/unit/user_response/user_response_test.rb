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

  test 'should process usages correctly' do
    @director.builder.process_specification_needs!
    actual_response = @director.get_response
    actual_specs_needs_for_mobilities = @director.builder.specification_needs_for_mobilities
    actual_specs_needs_for_usages = @director.builder.specification_needs_for_usages

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
    assert_in_delta actual_specs_needs_for_usages[5][0][1], 12.5, 0.001
    assert_in_delta actual_specs_needs_for_usages[11][0][0], 6, 0.001
    assert_in_delta actual_specs_needs_for_usages[32][0][0], 0, 0.001

    assert_in_delta actual_specs_needs_for_usages[5][1][0], 3, 0.001
    assert_in_delta actual_specs_needs_for_usages[6][1][1], 15, 0.001
    assert_in_delta actual_specs_needs_for_usages[16][1][0], 0, 0.001

    assert_in_delta actual_specs_needs_for_usages[3][5][1], 16.66667, 0.001
    assert_in_delta actual_specs_needs_for_usages[13][5][0], 10, 0.001
    assert_in_delta actual_specs_needs_for_usages[39][5][0], 0, 0.001
  end

  #see user_response_test.xlsx and sigmas.csv
  test 'should process sigmas correctly' do
    expected_sigmas = {1 => 0,2 => 5,3 => 4,4 => 4,5 => 4,6 => 6,7 => 0,9 => 7,10 => 0,11 => 6,12 => 0,13 => 10,14 => 0,15 => 0,16 => 0,17 => 0,18 => 0,19 => 0,20 => 0,23 => 0,30 => 0,31 => 0,32 => 0,33 => 0,34 => 0,35 => 0,36 => 0,37 => 0,38 => 0,39 => 0,40 => 0,41 => 0,42 => 0,43 => 0,44 => 0,45 => 0,46 => 0,47 => 0,48 => 0,49 => 0,81 => 0,82 => 0,83 => 0,84 => 5}
    @director.builder.process_specification_needs!
    @specification_needs_for_usages = @director.builder.specification_needs_for_usages
    assert !@specification_needs_for_usages.nil?, "@specification_needs_for_usages is nil"
    assert !@specification_needs_for_usages["1"], "@specification_needs_for_usages[1] is nil.\nspecification_needs_for_usages : #{@specification_needs_for_usages}"
    spec = Specification.all.first
    assert !@specification_needs_for_usages[spec.id].nil?, "@specification_needs_for_usages[spec.id] is nil.\nspec : #{spec}\nspec.id=#{spec.id.to_s}\n@specification_needs_for_usages[1] : #{@specification_needs_for_usages[1]}"
    needs_for_spec = @specification_needs_for_usages[spec.id]
    assert needs_for_spec.size == 6, "wrong size for needs_for_spec. \n needs_for_spec.size : #{needs_for_spec.size}"
    u_star_for_spec = @director.builder.specification_needs_to_u_star @specification_needs_for_usages, spec, "usages"
    assert u_star_for_spec.size == 6, "wrong size for u_star_for_spec\n u_star_for_spec : #{u_star_for_spec}\n u_star_for_spec.size : #{u_star_for_spec.size}"
    @director.builder.process_sigmas!
    @director.builder.sigmas.each do |spec_id, actual_sigma|
      assert_in_delta expected_sigmas[spec_id], actual_sigma, 0.001, "unexpected sigma for specification #{spec_id}"
    end
  end

  #see user_response_test.xslx and gammas.csv
  test 'should process gammas correctly' do
    expected_gammas = {1 => 0,2 => 27.74390244,3 => 0,4 => 0,5 => 10.67073171,6 => 19.20731707,7 => 0,9 => 9.024390244,10 => 0,11 => 27.74390244,12 => 0,13 => 0,14 => 0,15 => 0,16 => 0,17 => 0,18 => 0,19 => 0,20 => 0,23 => 0,30 => 0,31 => 0,32 => 0,33 => 0,34 => 0,35 => 0,36 => 0,37 => 0,38 => 0,39 => 0,40 => 0,41 => 0,42 => 0,43 => 0,44 => 0,45 => 0,46 => 0,47 => 0,48 => 0,49 => 0,81 => 0,82 => 0,83 => 0,84 => 5.609756098}
    @director.builder.process_specification_needs!
    @director.builder.process_gammas!
    @director.builder.gammas.each do |spec_id, actual_gamma|
      assert_in_delta expected_gammas[spec_id], actual_gamma, 0.001, "unexpected gamma for specification #{spec_id}"
    end
  end
end

