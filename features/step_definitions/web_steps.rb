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
  span_to_click = find(:xpath, "//input[@id=\'usage_choice_selected_#{usage_choice.id}\']/parent::*/span[@class='name']")
  span_to_click.click
end

When /^I press validate$/ do
  find(:xpath, "//div[@class=\'question opened selected\']/div/div/span").click
end

Then /^only super usages (.*) should be validated$/ do |super_usages_str|
  super_usages = super_usages_str.split(', ')

  are_super_usages_selected = true
  super_usages.each do |su|
    are_super_usages_selected = false unless page.has_xpath?("//div[@id=\"super-usage#{su.to_i}\" and @class=\"question selected button\"]")
  end

  should_super_usage_be_selected = true
  selected_super_usages = page.all(:xpath, "//div[@class=\"question selected button\"]")
  selected_super_usages.each do |su_element|
    selected_super_usage_id = su_element[:id].split('usage').last 
    should_super_usage_be_selected = false unless super_usages.include?(selected_super_usage_id) 
  end
  raise unless (are_super_usages_selected and should_super_usage_be_selected)
  #raise "selected_super_usages : #{selected_super_usages.inspect}"
end
