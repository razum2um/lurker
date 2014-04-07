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
