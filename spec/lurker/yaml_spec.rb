require 'spec_helper'

describe 'Yaml dump' do
  it 'dumps strings with slashes' do
    hash = { "extensions" => { "path_info" => "/api/v1/users/1/repos/1" } }
    expect(Psych.dump(hash)).to eq(
'---
extensions:
  path_info: "/api/v1/users/1/repos/1"
'
    )
  end
end
