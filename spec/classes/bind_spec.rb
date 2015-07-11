# ex: syntax=ruby ts=2 sw=2 si et
require 'spec_helper'

describe 'bind' do
  context "on a Debian OS" do
    let :facts do
      {
        :concat_basedir  => '/wtf',
        :osfamily        => 'Debian',
        :operatingsystem => 'Debian'
      }
    end
    it {
      should contain_package('bind-tools').with({
        'ensure' => 'latest',
        'name'   => 'dnsutils'
      }).that_comes_before('Package[bind]')
    }
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
  context "on a RedHat OS" do
    let :facts do
      {
        :concat_basedir  => '/wtf',
        :osfamily        => 'RedHat',
        :operatingsystem => 'CentOS'
      }
    end
    it {
      should contain_package('bind-tools').with({
        'ensure' => 'latest',
        'name'   => 'bind-utils'
      })
    }
    it {
      should contain_package('bind').with({
        'ensure' => 'latest',
        'name'   => 'bind'
      })
    }

    it { should contain_file('_NAMEDCONF_').that_requires('Package[bind]') }
    it { should contain_file('_NAMEDCONF_').that_notifies('Service[bind]') }

    it {
      should contain_service('bind').with({
        'ensure' => 'running',
        'name' => 'named'
      })
    }
  end
end
