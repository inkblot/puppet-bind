require 'puppet-lint/tasks/puppet-lint'

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
	config.fail_on_warnings
	config.relative = true
	config.ignore_paths = [ 'pkg/**/*.pp' ]
	config.disable_checks = [
		'80chars',
		'class_parameter_defaults',
		'documentation'
	]
end

task :default => [ :lint ]
