Given /^a checked file "([^"]*)" with:$/ do |file_name, file_content|
  write_file(file_name, file_content)

  @files ||= {}
  in_current_dir { @files[md5(file_name)] = checksum(file_name) }
end

Given /^an empty directory named "([^"]*)"$/ do |dir_name|
  in_current_dir { _rm_rf(dir_name) }
  create_dir(dir_name)
end

Given /^a service file with:$/ do |file_content|
  in_current_dir do
    write_file("#{Lurker::DEFAULT_SERVICE_PATH}/#{Rails.application.class.parent_name}#{Lurker::Service::SUFFIX}", file_content)
  end
end

When /^I go to "([^"]*)"$/ do |url|
  visit(url)
end

When /^I click on "([^"]*)"$/ do |text|
  find(:xpath, "//*[contains(text(),'#{text}')]").click
end

When /^I select "([^"]*)" hostname$/ do |host|
  puts "#" * 80
  puts "\n\nAbout to select #{host}"
  puts Nokogiri::XML(page.body).to_s
  puts "#" * 80
  within(:xpath, "//*[@id='hostname']") { select(host) }
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
  puts out
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

Then /(?:a|the) checked file "([^"]*)" should not change$/ do |file_name|
  in_current_dir do
    expect(@files.try(:[], md5(file_name))).to eq checksum(file_name)
  end
end

Then /(?:a|the) checked file "([^"]*)" should change$/ do |file_name|
  in_current_dir do
    expect(@files.try(:[], md5(file_name))).not_to eq checksum(file_name)
  end
end
