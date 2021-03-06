require 'test_helper'
require 'user_response'

class UserResponseTest < ActiveSupport::TestCase
  fixtures :user_requests, :usage_choices, :products
  include WizardUtilities

  def setup
    Rails.cache.clear
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
    #see user_response_test.xlsx, delta.csv and pi.csv
    #----------------------------
    #delta
    @director.builder.process_pi_and_delta!
    expected_delta ={16 => 151.081151,32 => 162.4503417,33 => 136.6927061,37 => 433.3837529,69 => 88.82506798,73 => 172.0068997,74 => 409.6176396,76 => 102.6773947,78 => 102.8272194,81 => 51.70312946,83 => 20.53238506,94 => 357.7391213,96 => 76.20768778,97 => 195.8369924,98 => 121.5408369,99 => 389.6393201,101 => 117.2366952,102 => 221.984675,103 => 255.1448134,104 => 149.2675469,105 => 171.5953039,106 => 140.2948461,107 => 139.3713775,110 => 284.8222576,111 => 221.1868708,112 => 229.7906628,113 => 389.0852545,114 => 20.53557566,117 => 112.6507392,120 => 124.1887208,121 => 412.8513679,122 => 81.85139342,123 => 68.29268293,124 => 68.29268293,125 => 110.9903049,126 => 68.29268293,127 => 229.7906628,129 => 105.4868948,130 => 20.53238506,131 => 73.8635767,132 => 115.6057622,134 => 389.6393201,136 => 389.0852545,137 => 165.4722784,140 => 389.0852545,143 => 155.7435675,147 => 76.25659925,148 => 76.25659925,149 => 389.0852545,150 => 389.0852545,151 => 76.25659925,154 => 170.1533964,155 => 409.6176396,156 => 174.281329,157 => 167.776662,158 => 117.1434748,159 => 82.14500965,160 => 117.5786815,161 => 41.03758423,162 => 412.8513679,163 => 412.8513679,164 => 409.6176396,166 => 3.901651404,168 => 412.8513679,169 => 409.6176396,170 => 101.5728592,171 => 361.8950342,172 => 71.44990588,173 => 93.60894292,174 => 79.99005862,175 => 252.4386847,178 => 96.7889843,179 => 76.25659925,180 => 110.1524324,182 => 114.1923636,183 => 290.0656259,185 => 257.5818828,186 => 117.5786815,188 => 412.8513679,189 => 110.1524324,190 => 73.07655786,191 => 175.2244539,192 => 151.4745147,194 => 221.6690308,195 => 188.7389359,196 => 243.6709424,197 => 221.6690308,198 => 132.5135345,200 => 110.1524324,201 => 153.7489439,202 => 77.48467917,203 => 152.7025946,204 => 385.1070819,205 => 151.4745147,206 => 110.1524324,207 => 136.7230526,208 => 389.0852545,209 => 103.6942658,210 => 119.7336325,211 => 389.0852545,213 => 385.1070819,214 => 409.6176396,215 => 433.3837529,216 => 69.66572915,218 => 0.307044849,219 => 99.25098018,220 => 130.9918623,221 => 108.3301083,222 => 151.4745147,225 => 70.12896755,228 => 76.89566534,229 => 117.5786815,230 => 90.65378502,232 => 102.8272194,233 => 97.78185997,234 => 22.2044106,235 => 22.2044106,236 => 100.9110595,237 => 100.9110595,238 => 153.7489439}
    #pi
    expected_pi ={16 => -9.173626421,32 => -12.72203816,33 => -3.60015919,37 => -154.6426054,69 => 58.69466743,73 => -0.141486739,74 => -142.6808121,76 => 25.03571722,78 => 21.26885977,81 => 122.3293512,83 => 90.29242628,94 => -97.16080176,96 => 42.7952243,97 => -9.082790998,98 => 1.229164562,99 => -117.4876833,101 => 5.244051333,102 => -31.31459109,103 => -60.01545431,104 => 6.174532255,105 => -22.96752277,106 => -19.45490026,107 => -7.066403669,110 => -76.03549931,111 => -44.91051486,112 => -19.12740945,113 => -118.2134363,114 => 154.9878799,117 => 4.823727904,120 => 25.80728975,121 => -131.6590643,122 => 24.15015374,123 => 76.24647269,124 => 131.3569663,125 => -42.26090015,126 => 60.9881805,127 => -26.82689192,129 => 59.46751346,130 => 125.2517202,131 => 70.30970827,132 => 12.12504199,134 => -108.9088616,136 => -119.5923028,137 => -33.00580702,140 => -117.7200462,143 => -55.45600482,147 => 43.13997088,148 => 43.13997088,149 => -118.7076698,150 => -118.7076698,151 => 24.90236018,154 => -31.97506845,155 => -142.8767717,156 => -38.4811208,157 => -35.22793425,158 => 13.03444783,159 => 15.86386044,160 => 1.560716932,161 => 149.2603826,162 => -129.6818396,163 => -129.6818396,164 => -143.6634744,166 => 99.27813761,168 => -131.7013376,169 => -142.8767717,170 => 28.32570516,171 => -100.4935016,172 => 124.0972343,173 => 101.8214911,174 => 39.13798154,175 => -78.82145056,178 => 12.17082182,179 => 42.22942027,180 => 15.82897398,182 => 6.776784247,183 => -82.34169729,185 => -58.13273301,186 => 53.06368329,188 => -131.7013376,189 => -0.329103796,190 => 83.30517571,191 => -30.62613813,192 => -12.29558503,194 => -59.28634211,195 => -44.94577639,196 => -70.44108142,197 => -66.47206123,198 => 5.289603099,200 => -1.597440596,201 => -13.50208164,202 => 39.62412709,203 => -14.41080362,204 => -112.5992066,205 => -14.99136982,206 => -0.329103796,207 => -16.04282814,208 => -117.7067896,209 => 5.771237683,210 => 27.09693001,211 => -117.7200462,213 => -112.5992066,214 => -143.6634744,215 => -154.8385651,216 => 120.853732,218 => 111.0531117,219 => 21.3276649,220 => 7.238328751,221 => 75.97163578,222 => 9.106353542,225 => 50.15262463,228 => 59.66010674,229 => 26.98644162,230 => 122.2861954,232 => 21.26885977,233 => 71.93509252,234 => 131.8437095,235 => 157.2046682,236 => 70.62319928,237 => 125.0136551,238 => -24.25179959}
    @director.builder.products_for_calculations.each do |ps|
      product_id = ps.product.id
      assert_in_delta expected_delta[product_id], ps.delta, 0.001, "unexpected delta for specification #{product_id}"
      assert_in_delta expected_pi[product_id], ps.pi, 0.001, "unexpected pi for specification #{product_id}"
    end
    #----------------------------
    #spenta_score processing
    #see user_response_test.xslx and scores.csv
    #----------------------------
    @director.builder.process_scores!
    expected_scores ={16 => 77.39980154,32 => 75.43959626,33 => 79.88056792,37 => 28.72693915,69 => 88.13360897,73 => 73.79191384,74 => 32.8245449,76 => 85.74527677,78 => 85.71944493,81 => 94.5339432,83 => 99.90820947,94 => 41.76911702,96 => 90.30901935,97 => 69.68327717,98 => 82.49295916,99 => 36.26908274,101 => 83.23505255,102 => 65.17505604,103 => 59.4577908,104 => 77.71249191,105 => 73.86287863,106 => 79.2595093,107 => 79.41872801,110 => 54.34099007,111 => 65.31260848,112 => 63.82919607,113 => 36.36461129,114 => 99.90765937,117 => 84.02573462,120 => 82.03642744,121 => 32.26700554,122 => 89.33596665,123 => 91.67367536,124 => 91.67367536,125 => 84.3120164,126 => 91.67367536,127 => 63.82919607,129 => 85.2608802,130 => 99.90820947,131 => 90.71317643,132 => 83.5162479,134 => 36.26908274,136 => 36.36461129,137 => 74.91857269,140 => 36.36461129,143 => 76.59593664,147 => 90.30058634,148 => 90.30058634,149 => 36.36461129,150 => 36.36461129,151 => 90.30058634,154 => 74.11148339,155 => 32.8245449,156 => 73.39977087,157 => 74.52126517,158 => 83.25112503,159 => 89.28534316,160 => 83.17608939,161 => 96.37283031,162 => 32.26700554,163 => 32.26700554,164 => 32.8245449,166 => 100,168 => 32.26700554,169 => 32.8245449,170 => 85.93571392,171 => 41.05258032,172 => 91.12932657,173 => 87.30880295,174 => 89.65688644,175 => 59.92436471,178 => 86.76051995,179 => 90.30058634,180 => 84.45647717,182 => 83.7599373,183 => 53.43696105,185 => 59.03760642,186 => 83.17608939,188 => 32.26700554,189 => 84.45647717,190 => 90.84886933,191 => 73.23716313,192 => 77.33198023,194 => 65.22947745,195 => 70.90708001,196 => 61.43604442,197 => 65.22947745,198 => 80.60111474,200 => 84.45647717,201 => 76.93983726,202 => 90.08884842,203 => 77.12024231,204 => 37.05050312,205 => 77.33198023,206 => 84.45647717,207 => 79.87533576,208 => 36.36461129,209 => 85.56995417,210 => 82.80454611,211 => 36.36461129,213 => 37.05050312,214 => 32.8245449,215 => 28.72693915,216 => 91.43694325,218 => 104.7099896,219 => 86.3360379,220 => 80.86347201,221 => 84.77067098,222 => 77.33198023,225 => 91.35707456,228 => 90.19040253,229 => 83.17608939,230 => 87.81831293,232 => 85.71944493,233 => 86.58933449,234 => 99.61992921,235 => 99.61992921,236 => 86.04981733,237 => 86.04981733,238 => 76.93983726}
    @director.builder.products_for_calculations.each do |ps|
      product_id = ps.product.id
      assert_in_delta expected_scores[product_id], ps.spenta_score, 0.001, "unexpected score for specification #{product_id}"
    end
    #----------------------------
    # good_deals processing
    #----------------------------
    @director.builder.process_good_deals!
    actual_good_deals = []
    @director.builder.products_for_calculations.each { |p| actual_good_deals << p if p.is_good_deal }
    expected_good_deals = [83, 151, 166, 174, 178, 201, 205, 218, 228, 191]
    assert actual_good_deals.size == 10, "size of good_deals : #{actual_good_deals.size}"
    actual_good_deals.each { |p| assert expected_good_deals.include?(p.product.id), "product #{p.product.id} not in expected good_deals" }
    assert actual_good_deals = actual_good_deals.uniq, "duplicate products in good_deals"
    #----------------------------
    # stars processing
    #----------------------------
    @director.builder.process_stars!
    actual_stars = []
    @director.builder.products_for_calculations.each { |p| actual_stars << p if p.is_star }
    expected_stars = [178,174,83]
    assert actual_stars.size == 3, "size of stars : #{actual_stars.size}"
    actual_stars.each { |p| assert expected_stars.include?(p.product.id) , "product #{p.product.id} not in expected stars"}
    assert actual_stars = actual_stars.uniq, "duplicate products in stars"
  end

  test 'should remove products with low scores' do
    product = products(:product_76)
    p1, p2, p3, p4 = ProductForCalculations.new(product), ProductForCalculations.new(product), ProductForCalculations.new(product), ProductForCalculations.new(product)
    p1.spenta_score, p2.spenta_score, p3.spenta_score, p4.spenta_score = 30, 70, 71, 100

    products_for_calculations = [p1, p2, p3, p4]
    products_with_low_scores = @director.builder.remove_low_scores_from products_for_calculations
    assert products_with_low_scores == [p1]
    assert products_for_calculations == [p2, p3, p4]
  end

  test 'should add products to good deals' do
    p_162 = Product.find(162) #price = 229. The usual syntax p_162 = products(:product_162) doesn't work for some reason
    p_134 = Product.find(134) #price = 229
    p_37 = Product.find(37) #price = 239
    p_211 = Product.find(211) #price = 249
    p_163 = Product.find(163) #price = 249

    ps_37, ps_163, ps_162, ps_211, ps_134 = ProductForCalculations.new(p_37), ProductForCalculations.new(p_163), ProductForCalculations.new(p_162), ProductForCalculations.new(p_211), ProductForCalculations.new(p_134)

    ps_134.spenta_score = 25
    ps_162.spenta_score = 20
    ps_37.spenta_score = 27
    ps_211.spenta_score = 42
    ps_163.spenta_score = 43

    products_for_calculations = [ps_37, ps_163, ps_162, ps_211, ps_134]

    remaining_products = @director.builder.add_to_good_deals_from products_for_calculations
    assert @director.builder.good_deals == [ps_134, ps_37, ps_163], "good_deals : #{@director.builder.good_deals}"
    assert remaining_products == [ps_162, ps_211], "remaining_products : #{remaining_products}"
  end

  test 'should complete array' do
    initial_array = %w{one two}
    first_new_array = %w{three four}
    second_new_array = %w{five six}
    @director.builder.complete initial_array, :with => first_new_array, :until_size_is => 3, :by => :length, :order =>:desc,:and_delete_from_source => true
    assert initial_array = %{one two three}
    assert first_new_array = ["four"]
    @director.builder.complete initial_array, :with => second_new_array, :until_size_is => 4, :by => :length, :order =>:asc,:and_delete_from_source => false
    assert initial_array = %{one two three six}
    assert second_new_array = ["five", "six"]
  end

  test 'should complete good deals' do
    expected_good_deals = [191, 157,137,156,105,73,154,195,97,111]
    builder = @director.builder
    builder.process_specification_needs!
    builder.process_sigmas!
    builder.process_gammas!
    builder.process_pi_and_delta!
    builder.process_scores!
    #removes all products with scores > 75. See good_deals_test_compl sheet in the xlsx file for more details
    low_scores = []
    builder.products_for_calculations.each {|p| low_scores << p if p.spenta_score > 75}
    low_scores.each { |p| builder.products_for_calculations.delete p }
    builder.process_good_deals!
    actual_good_deals = builder.good_deals
    assert actual_good_deals.size == 10, "size : #{actual_good_deals.size}"
    actual_good_deals.each { |p| assert expected_good_deals.include? p.product.id }
    assert actual_good_deals = actual_good_deals.uniq
  end

  test 'should restrict good deals' do
    expected_good_deals = [151,238,180,117,160,202,174,218,83,166]
    builder = @director.builder
    builder.process_specification_needs!
    builder.process_sigmas!
    builder.process_gammas!
    builder.process_pi_and_delta!
    builder.process_scores!
    #removes some products to get enough good deals after the first step. See good_deals_test_compl sheet in the xlsx file for more details
    products_to_remove = []
    builder.products_for_calculations.each { |p| products_to_remove << p if [201,192,178,200,205,219,228].include? p.product.id  }
    products_to_remove.each { |p| builder.products_for_calculations.delete p }
    builder.process_good_deals!
    actual_good_deals = builder.good_deals
    assert actual_good_deals.size == 10, "size : #{actual_good_deals.size}"
    actual_good_deals.each { |p| assert expected_good_deals.include? p.product.id }
    assert actual_good_deals = actual_good_deals.uniq
  end
end
