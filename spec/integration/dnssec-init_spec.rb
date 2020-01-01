# ex: syntax=ruby ts=2 sw=2 si et
require 'spec_helper'

describe 'dnssec-init should create RSASHA256 KSK and ZSK' do
  fixture_file '../../files/dnssec-init'
  fixture_file 'files/zones'
  command '/bin/sh dnssec-init . example.com example.com . /dev/urandom 12345678 example.com.zone'
  its(:stdout) { is_expected.to match(/^Kexample\.com\.\+008\+[0-9]+\nKexample\.com\.\+008\+[0-9]+\n\.\/example\.com\/example\.com\.zone\.signed$/m) }
end

describe 'dnssec-init should create RSASHA256 KSK only' do
  fixture_file '../../files/dnssec-init'
  fixture_file 'files/zones'
  command '/bin/sh dnssec-init . example.com example.com . /dev/urandom 12345678 example.com.zone true'
  its(:stdout) { is_expected.to match(/^Kexample\.com\.\+008\+[0-9]+\n\.\/example\.com\/example\.com\.zone\.signed$/m) }
end