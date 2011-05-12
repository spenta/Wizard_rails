require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(*selector_for(locator)) { yield } : yield
  end
end
World(WithinHelpers)

Given /^a set of usages and super usages$/ do
    fixtures_folder = File.join(Rails.root.to_s, 'test', 'fixtures')
    Fixtures.create_fixtures(fixtures_folder, %w{usages super_usages user_requests usage_choices})
end

When /^(?:|I )am on (.*)$/ do |page|
  visit path_to(page)
end

When /^(?:|I )follow "([^"]*)"$/ do |link|
  click_link(link)
  @user_request = UserRequest.last
end

When /^I select super usage (\d+)$/ do |number|
  find_by_id("super-usage#{number}").click
end

When /^I select usage (\d+)$/ do |number|
  usage_choice = @user_request.usage_choices.select{|uc| uc.usage_id == number.to_i}.first
  span_to_click = find(:xpath, %{//input[@id=\'usage_choice_selected_#{usage_choice.id}\']/parent::*/span[@class='name']})
  span_to_click.click
end

When /^I press validate$/ do
  find(:xpath, %{//div[@class='question opened selected' or @class='question opened']/div/div/span}).click
end

When /^I press not interested$/ do
  find(:xpath, %{//div[@class='question opened selected' or @class='question selected opened']/div/div/label[@class='checkbox none']/span[@class='name']}).click
end

When /^I click on next$/ do
  click_button 'user_request_submit' 
end

Then /^no super usages should be selected$/ do
  SuperUsage.all.collect{|su| su.id}.each do |su_id|
    raise "no usages should be selected" if page.has_xpath?(%{//div[@id="super-usage#{su_id}" and @class="question selected button"]})
  end
end

Then /^only super usages (.*) should be selected/ do |super_usages_str|
  super_usages = super_usages_str.split(', ')

  #check if super usages which should be selected are actually selected
  are_super_usages_selected = true
  super_usages.each do |su|
    are_super_usages_selected = false unless page.has_xpath?("//div[@id=\"super-usage#{su.to_i}\" and @class=\"question selected button\"]")
  end

  #check if only super usages which should be selected are actually selected
  should_super_usage_be_selected = true
  selected_super_usages = page.all(:xpath, "//div[@class=\"question selected button\"]")
  selected_super_usages.each do |su_element|
    selected_super_usage_id = su_element[:id].split('usage').last 
    should_super_usage_be_selected = false unless super_usages.include?(selected_super_usage_id) 
  end
  raise unless (are_super_usages_selected and should_super_usage_be_selected)
end

Then /^I should be on the (.+) step$/ do |step|
  #As we can't access sessions variables, we check the page's title
  actual_page_title = find(:xpath, "//h1").text
  expected_page_title = I18n.t("#{step}_step_title".to_sym)
  raise "page title should be #{expected_page_title} but is #{actual_page_title}" unless actual_page_title == expected_page_title
end

Then /^I can change weight only for super usages (.*)/ do |ids_str|
  ids = ids_str.split(', ')
  
  #check if super usages which should be present are actually present
  are_super_usages_present = true
  ids.each do |su_id|
    are_super_usages_present = false unless page.has_xpath?("//div[@id=\'super-usage#{su_id}\']")
  end
  
  #check if only super usages which should be present are actually present
  should_super_usage_be_present = true
  present_super_usages = page.all(:xpath, %{//div[@class='question']})
  present_ids = present_super_usages.collect{|su| su[:id].split('usage').last}
  present_ids.each do |su_id|
    should_super_usage_be_present = false unless ids.include?(su_id)
  end
  raise "wrong super usages present\n\super usages should be #{ids.inspect} but is #{present_ids.inspect}" unless (are_super_usages_present and should_super_usage_be_present)
end

Then /^weight for super usage (\d+) should be (\d+)$/ do |su_id, weight|
  actual_weight = find(:xpath, "//div[@id=\'super-usage#{su_id}\']/div/div[@class=\'answer\']/select/option").value
  raise "wrong weight, expected #{weight} but was #{actual_weight}" unless actual_weight == weight
end

Then /^(?:|I )should see (?:the|a|an) "([^"]*)" error$/ do |error_str|
  error_sym = error_str.gsub(" ","_").to_sym
  error_message = I18n.t(error_sym)
  raise "there should be a #{error_message} message" unless page.has_content?(error_message)
end
