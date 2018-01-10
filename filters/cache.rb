require 'json'
require 'digest/sha2'
require 'fileutils'

module Cache # :nodoc:
  CACHE = File.expand_path('../../cache', __FILE__)

  def self.fetch(raw_key)
    key = Digest::SHA256.hexdigest(raw_key)

    begin
      return JSON.parse(File.read(File.join(CACHE, key)))
    rescue Errno::ENOENT
      nil
    end

    ret = yield

    FileUtils.mkdir(CACHE) unless Dir.exist?(CACHE)
    File.write(File.join(CACHE, key), JSON.dump(ret))

    ret
  end
end
