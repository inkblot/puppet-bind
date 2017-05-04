source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :test do
  puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 4.9']
  gem "metadata-json-lint"
  gem "puppet", puppetversion
  gem "puppetlabs_spec_helper"
  gem "rake"
  gem "rspec", '> 3.4.0'
  gem "rspec-puppet"
  gem "rspec-puppet-facts"
  gem 'rubocop'
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'

  gem "puppet-lint-absolute_classname-check"
  gem "puppet-lint-classes_and_types_beginning_with_digits-check"
  gem "puppet-lint-leading_zero-check"
  gem 'puppet-lint-resource_reference_syntax'
  gem "puppet-lint-trailing_comma-check"
  gem "puppet-lint-unquoted_string-check"
  gem "puppet-lint-version_comparison-check"

  gem 'json_pure', '<= 2.0.1' if RUBY_VERSION < '2.0.0'
end

group :development do
  gem "guard-rake" if RUBY_VERSION >= '2.2.5' # per dependency https://rubygems.org/gems/ruby_dep
  gem "puppet-blacksmith"
  gem 'puppet-strings'
  gem "travis" if RUBY_VERSION >= '2.1.0'
  gem "travis-lint" if RUBY_VERSION >= '2.1.0'
  gem 'yard'
end

group :system_tests do
  gem "beaker"
  gem "beaker-puppet_install_helper"
  gem "beaker-rspec"
end
