# ex: syntax=ruby ts=2 sw=2 si et
require 'spec_helper'

describe 'bind::chroot::package' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      # Only applies to RedHat Family for now:
      next unless facts[:os]['family'] == 'RedHat'
      let(:facts) { facts }

      context 'with defaults parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('bind-chroot').with({ ensure: 'latest', }) }
        it do
          is_expected.to contain_service('bind-without-chroot').with({
                                                                       ensure: 'stopped',
            enable: false,
            name: 'named'
                                                                     })
        end
        it do
          is_expected.to contain_service('bind').with({
                                                        ensure: 'running',
            enable: true,
            name: 'named-chroot'
                                                      })
        end
      end
    end
  end
end
