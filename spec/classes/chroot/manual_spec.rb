# ex: syntax=ruby ts=2 sw=2 si et
require 'spec_helper'

describe 'bind::chroot::manual' do
  let(:pre_condition) do
    "
    class { 'bind':
        chroot                => true,
        default_zones_include => '/etc/named/default-zones.conf',
        forwarders            => [
            '8.8.8.8',
            '8.8.4.4',
        ],
        dnssec                => true,
        version               => 'Controlled by Puppet',
    }
    "
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      # Only applies to Debian Family for now:
      next if facts[:os]['family'] != 'Debian'
      next if facts[:os]['name'] != 'Debian'
      next if (facts[:os]['name'] == 'Debian') && (facts[:os]['release']['major'].to_i < 8)
      let(:facts) { facts }

      context 'with defaults parameters' do
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
