require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

exclude_paths = [
  'bundle/**/*',
  'pkg/**/*',
  'vendor/**/*',
  'spec/**/*'
]

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  config.fail_on_warnings = true
  config.ignore_paths = exclude_paths
  config.disable_checks = [
    '80chars',
    'class_parameter_defaults',
    'documentation',
    'autoloader_layout'
  ]
end

PuppetSyntax.exclude_paths = exclude_paths

RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

task :metadata do
  sh 'metadata-json-lint metadata.json'
end

desc 'Run syntax, lint, and spec tests.'
task :test => [
  :syntax,
  :lint,
  :spec,
  :metadata
]
