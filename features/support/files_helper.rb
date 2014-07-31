def md5(file_name)
  Digest::MD5.hexdigest(file_name)
end

def checksum(file_name)
  Digest::SHA2.hexdigest(File.read file_name)
end
