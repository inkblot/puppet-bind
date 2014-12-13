require 'puppet-lint/tasks/puppet-lint'

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
	config.fail_on_warnings
	config.ignore_paths = [ 'pkg/**/*.pp' ]
	config.disable_checks = [
		'80chars',
		'class_parameter_defaults',
		'documentation',
		'autoloader_layout'
	]
end

task :default => [ :lint ]
