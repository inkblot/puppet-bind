require 'rspec-puppet'

RSpec.configure do |c|
  c.module_path = File.expand(File.join(__FILE__, '..', 'fixtures', 'modules'))
  c.manifest_dir = File.expand(File.join(__FILE__, '..', 'fixtures', 'manifests'))
end
