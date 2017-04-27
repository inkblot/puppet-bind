# ex: syntax=ruby ts=2 sw=2 si et
require 'spec_helper'

describe 'bind' do
  context "on a Debian OS" do
    let :facts do
      {
        :concat_basedir  => '/wtf',
        :osfamily        => 'Debian',
        :os => {
          :family => 'Debian',
        },
        :operatingsystem => 'Debian'
      }
    end
    it { is_expected.to compile }
    it do
      should contain_package('bind-tools').with({
        ensure: 'present',
        name: 'dnsutils'
      })
    end
    it do
      should contain_package('bind').with({
        ensure: 'latest',
        name: 'bind9'
      })
    end

    it { should contain_file('/etc/bind/named.conf').that_requires('Package[bind]') }
    it { should contain_file('/etc/bind/named.conf').that_notifies('Service[bind]') }

    it {
      should contain_service('bind').with({
        ensure: 'running',
        name: 'bind9'
      })
    }
  end
  context "on a RedHat OS" do
    let :facts do
      {
        :concat_basedir  => '/wtf',
        :osfamily        => 'RedHat',
        :os => {
          :family => 'RedHat',
        },
        :operatingsystem => 'CentOS'
      }
    end
    it {
      should contain_package('bind-tools').with({
        'ensure' => 'present',
        'name'   => 'bind-utils'
      })
    }
    it {
      should contain_package('bind').with({
        'ensure' => 'latest',
        'name'   => 'bind'
      })
    }

    it { should contain_file('/etc/named.conf').that_requires('Package[bind]') }
    it { should contain_file('/etc/named.conf').that_notifies('Service[bind]') }

    it {
      should contain_service('bind').with({
        'ensure' => 'running',
        'name' => 'named'
      })
    }
  end
end
