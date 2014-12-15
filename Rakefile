# ex: syntax=ruby ts=2 ts=2 si et
require 'puppet-lint/tasks/puppet-lint'
require 'puppetlabs_spec_helper/rake_tasks'

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.fail_on_warnings
  config.ignore_paths = [ 'pkg/**/*', 'spec/**/*', 'gemfiles/vendor/**/*' ]
  config.disable_checks = [
    '80chars',
    'class_parameter_defaults',
    'documentation',
    'autoloader_layout'
  ]
end

task :default => [ :spec, :lint ]
