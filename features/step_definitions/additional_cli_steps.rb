When /^I go to "([^"]*)"$/ do |url|
  visit(url)
end

When /^I click on "([^"]*)"$/ do |text|
  find(:xpath, "//*[contains(text(),'#{text}')]").click
end

Given /^an empty directory named "([^"]*)"$/ do |dir_name|
  FileUtils.rm_rf File.expand_path("../../../tmp/example_app/#{dir_name}", __FILE__)
  create_dir(dir_name)
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
  expect(find(:xpath, "//*[contains(text(),'#{text}')]")).to be
end

Then /^I should see "([^"]*)" within "([^"]*)"$/ do |text, selector|
  expect(find(:xpath, "//#{selector}[contains(text(),'#{text}')]")).to be
end

Then /^the output should contain failures:$/ do |failures|
  out = all_output.dup
  failures.split(/\n/).map(&:strip).each do |failure|
    next if failure.blank?
    expect(out).to match /#{Regexp.escape(failure)}/
    out.gsub!(/.*?#{Regexp.escape(failure)}/m, '')
  end
end
