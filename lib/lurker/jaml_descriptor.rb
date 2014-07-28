# file encoded in YAML
# readed as dumped JSON
# to hack `open('...json').read`
class Lurker::JamlDescriptor
  module Rescue
    def open(uri)
      Kernel.open(uri)
    rescue Errno::ENOENT
      Lurker::JamlDescriptor.new(uri)
    end
  end

  def initialize(uri)
    @uri = uri.gsub(/\#$/, '').gsub(/\.json/, '.json.yml')
    @fd = open(@uri)
  end

  def read
    @read ||= JSON.dump(YAML.load(@fd.read))
  end
end
