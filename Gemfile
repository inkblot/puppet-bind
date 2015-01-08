source 'https://rubygems.org'

if ENV.include?('PUPPET_VERSION')
  puppetversion = "~>#{ENV['PUPPET_VERSION']}"
else
  puppetversion = '~>3.7.0'
end

gem 'rake'
gem 'puppet', puppetversion
gem 'puppet-lint'
gem 'rspec-puppet'
gem 'puppetlabs_spec_helper'
gem 'metadata-json-lint'
