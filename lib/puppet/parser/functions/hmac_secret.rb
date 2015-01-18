# ex: syntax=ruby si sw=2 ts=2 et
require 'securerandom'

module Puppet::Parser::Functions
  newfunction(:hmac_secret, :type => :rvalue) do |args|
    bits = args[0].to_i
    SecureRandom.base64(bits / 8)
  end
end
