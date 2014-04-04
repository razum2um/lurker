class Lurker::RefObject
  def initialize(ref_path, root_path)
    @ref_path = ref_path
    @root_path = root_path
  end

  def schema
    return @ref_schema if @ref_schema
    return {} if @ref_path.nil? || @root_path.nil?
    @ref_schema = JSON.parse(schema_descriptor.read)
  end

  def schema_descriptor
    open(abs_path.to_s)
  rescue Errno::ENOENT
    Lurker::JamlDescriptor.new(abs_path.to_s)
  end

  def abs_path
    @abs_path ||= @root_path.merge(URI.parse(@ref_path)).tap { |u| u.fragment = nil }
  end
end
