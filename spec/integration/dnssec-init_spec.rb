# ex: syntax=ruby ts=2 sw=2 si et
require 'spec_helper'

describe 'dnssec-init should create RSASHA256 KSK(2048) and ZSK(1024)' do
  fixture_file '../../files/dnssec-init'
  fixture_file 'files/zones'
  command '/bin/sh dnssec-init . example.com example.com . /dev/urandom 12345678 example.com.zone false RSASHA256 2048 1024'
  its(:stdout) { is_expected.to match(/^Kexample\.com\.\+008\+[0-9]+\nKexample\.com\.\+008\+[0-9]+\n\.\/example\.com\/example\.com\.zone\.signed$/m) }
end

describe 'dnssec-init should create RSASHA256 KSK(2048) only' do
  fixture_file '../../files/dnssec-init'
  fixture_file 'files/zones'
  command '/bin/sh dnssec-init . example.com example.com . /dev/urandom 12345678 example.com.zone true RSASHA256 2048 1024'
  its(:stdout) { is_expected.to match(/^Kexample\.com\.\+008\+[0-9]+\n\.\/example\.com\/example\.com\.zone\.signed$/m) }
end

describe 'dnssec-init should create RSASHA256 KSK(4096) and ZSK(2048)' do
  fixture_file '../../files/dnssec-init'
  fixture_file 'files/zones'
  command '/bin/sh dnssec-init . example.com example.com . /dev/urandom 12345678 example.com.zone false RSASHA256 4096 2048'
  its(:stdout) { is_expected.to match(/^Kexample\.com\.\+008\+[0-9]+\n\.\/example\.com\/example\.com\.zone\.signed$/m) }
end

describe 'dnssec-init should create ECDSAP256SHA256 KSK and ZSK' do
  fixture_file '../../files/dnssec-init'
  fixture_file 'files/zones'
  command '/bin/sh dnssec-init . example.com example.com . /dev/urandom 12345678 example.com.zone false ECDSAP256SHA256'
  its(:stdout) { is_expected.to match(/^Kexample\.com\.\+013\+[0-9]+\nKexample\.com\.\+013\+[0-9]+\n\.\/example\.com\/example\.com\.zone\.signed$/m) }
end
