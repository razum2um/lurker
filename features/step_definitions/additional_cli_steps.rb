Given /^a checked file "([^"]*)" with:$/ do |file_name, file_content|
  write_file(file_name, file_content)

  @files ||= {}
  in_current_directory { @files[md5(file_name)] = checksum(file_name) }
end

Given /^a service file with:$/ do |file_content|
  in_current_directory do
    rails_app_class = Rails.application.class
    rails_app_name = rails_app_class.respond_to?(:module_parent_name) ? rails_app_class.module_parent_name : rails_app_class.parent_name
    write_file("#{Lurker::DEFAULT_SERVICE_PATH}/#{rails_app_name}#{Lurker::Service::SUFFIX}", file_content)
  end
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
end

When /^I select "([^"]*)" request media type$/ do |type|
  within(:xpath, "//*[@id='requestMediaType']") do
    select(type)
  end
  # FIXME: cannot select node in phantomjs
  page.execute_script("window.submitForm.setState({requestMediaType: jQuery('#requestMediaType').val()});")
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
    next if line.strip!.blank?
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

Then /(?:a|the) checked file "([^"]*)" should not change$/ do |file_name|
  in_current_directory do
    expect(@files.try(:[], md5(file_name))).to eq checksum(file_name)
  end
end

Then /(?:a|the) checked file "([^"]*)" should change$/ do |file_name|
  in_current_directory do
    expect(@files.try(:[], md5(file_name))).not_to eq checksum(file_name)
  end
end
