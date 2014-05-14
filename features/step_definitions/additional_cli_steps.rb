Given /^an empty directory named "([^"]*)"$/ do |dir_name|
  FileUtils.rm_rf File.expand_path("../../../tmp/lurker_app/#{dir_name}", __FILE__)
  create_dir(dir_name)
end

When /^I go to "([^"]*)"$/ do |url|
  visit(url)
end

When /^I click on "([^"]*)"$/ do |text|
  find(:xpath, "//*[contains(text(),'#{text}')]").click
end

When /^I select "([^"]*)" hostname$/ do |host|
  within(:xpath, "//*[@id='hostname']") do
    select(host)
  end
  # FIXME: see multidomain feature - cannot select node in phantomjs
  page.execute_script("window.submitForm.setState({host: jQuery('#hostname').val()});")
  page.execute_script("window.submitForm.afterSetPartialState()")
end

When(/^I fill in the submit form field "([^"]*)" with "([^"]*)"$/) do |field, name|
  fill_in("user[#{field}]", with: name)
end

When(/^I fill in the submit form url-field "([^"]*)" with "([^"]*)"$/) do |field, name|
  fill_in("_url_params[#{field}]", with: name)
end

When(/^I submit lurk form$/) do
  find(:xpath, "//*[@type='submit']").click
end

When(/^I submit it$/) do
  find(:xpath, "//*[@type='submit']").click
end

Then /^the example(s)? should( all)? pass$/ do |_, _|
  step %q{the output should contain "0 failures"}
  step %q{the exit status should be 0}
end

Then /^the file "([^"]*)" should contain JSON-Schema:$/ do |file, schema|
  prep_for_fs_check do
    content = IO.read(file)
    # TODO: match schema via schema
  end
end

Then /^I should see "([^"]*)"$/ do |text|
  expect(page).to have_content text
end

Then /^I should see:$/ do |text|
  expect(page).to have_content text
end

Then /^I should see "([^"]*)" within "([^"]*)"$/ do |text, selector|
  expect(find(:xpath, "//#{selector}[contains(text(),'#{text}')]")).to be
end

Then /^the output should contain (failures|these lines):$/ do |_, lines|
  out = all_output.dup
  lines.split(/\n/).map(&:strip).each do |line|
    next if line.blank?
    expect(out).to match /#{Regexp.escape(line)}/
    out.gsub!(/.*?#{Regexp.escape(line)}/m, '')
  end
end

Then /^the output should contain unescaped (failures|these lines):$/ do |_, lines|
  out = all_output.dup
  lines.split(/\n/).map(&:strip).each do |line|
    next if line.blank?
    expect(out).to match /#{line}/
    out.gsub!(/.*?#{line}/m, '')
  end
end

Then(/^I should see JSON response with "([^"]*)"$/) do |name|
  within(find(:xpath, "//*[@id='show-api-response-div']")) do
    expect(page).to have_content name
  end
end
