require 'json-schema/validator'

class Lurker::Validator < JSON::Validator
  def open(uri)
    Kernel.open(uri)
  rescue Errno::ENOENT
    Lurker::JamlDescriptor.new(uri)
  end
end

