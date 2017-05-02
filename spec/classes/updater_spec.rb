require 'spec_helper'

describe 'bind::updater' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let (:facts) {facts}
      case facts[:os]['family']
        when 'Debian'
          expected_bind_tools_pkg = 'dnsutils'
        when 'RedHat'
          expected_bind_tools_pkg = 'bind-utils'
      end
      context 'with defaults for all parameters' do
        it { is_expected.to compile }
        it { is_expected.to compile.with_all_deps }
      end
      it do
        is_expected.to contain_package('bind-tools').with({
          ensure: 'present',
          name: expected_bind_tools_pkg
        })
      end
    end
  end
end
