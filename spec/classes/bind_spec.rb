# ex: syntax=ruby ts=2 sw=2 si et
require 'spec_helper'

describe 'bind' do
  let(:facts) { { :concat_basedir => '/wtf' } }

  it {
    should contain_package('bind').with({
      'ensure' => 'latest',
      'name' => 'bind9'
    })
  }

  it { should contain_file('_NAMEDCONF_').that_requires('Package[bind]') }
  it { should contain_file('_NAMEDCONF_').that_notifies('Service[bind]') }

  it {
    should contain_service('bind').with({
      'ensure' => 'running',
      'name' => 'bind9'
    })
  }

end
