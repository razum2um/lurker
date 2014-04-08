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
