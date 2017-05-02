# ex: syntax=ruby ts=2 sw=2 si et
require 'spec_helper'
require 'pp'

describe 'bind' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let (:facts) {facts}
      case facts[:os]['family']
        when 'Debian'
          expected_bind_tools_pkg = 'dnsutils'
          expected_bind_pkg = 'bind9'
          expected_bind_service = 'bind9'
          expected_named_conf = '/etc/bind/named.conf'
        when 'RedHat'
          expected_bind_tools_pkg = 'bind-utils'
          expected_bind_pkg = 'bind'
          expected_bind_service = 'named'
          expected_named_conf = '/etc/named.conf'
      end
      context 'with defaults for all parameters' do
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_package('bind-tools').with({
            ensure: 'present',
            name: expected_bind_tools_pkg
          })
        end
        it do
          is_expected.to contain_package('bind').with({
            ensure: 'latest',
            name: expected_bind_pkg
          })
        end
        it { is_expected.to contain_file(expected_named_conf).that_requires('Package[bind]') }
        it { is_expected.to contain_file(expected_named_conf).that_notifies('Service[bind]') }
        it do
          is_expected.to contain_service('bind').with({
            ensure: 'running',
            name: expected_bind_service
          })
        end
      end
    end
  end
end
