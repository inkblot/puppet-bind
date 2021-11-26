# ex: syntax=ruby ts=2 sw=2 si et
require 'spec_helper'

describe 'bind' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      case facts[:os]['family']
      when 'Debian'
        expected_bind_pkg             = 'bind9'
        expected_bind_service         = 'bind9'
        expected_named_conf           = '/etc/bind/named.conf'
        expected_confdir              = '/etc/bind'
        expected_default_zones_include = '/etc/bind/named.conf.default-zones'
      when 'RedHat'
        expected_bind_pkg             = 'bind'
        expected_bind_service         = 'named'
        expected_named_conf           = '/etc/named.conf'
        expected_confdir              = '/etc/named'
        expected_default_zones_include = '/etc/named.default-zones.conf'
      end
      context 'with defaults for all parameters' do
        it { is_expected.to contain_class('bind::keydir') }
        it { is_expected.to contain_class('bind::updater') }
        it { is_expected.to contain_class('bind') }
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_package('bind').with({
                                                        ensure: 'latest',
            name: expected_bind_pkg
                                                      })
        end
        it { is_expected.to contain_file('/usr/local/bin/dnssec-init') }
        it do
          is_expected.to contain_bind__key('rndc-key').with(
            algorithm: 'hmac-md5',
            secret_bits: '512',
            keydir: expected_confdir,
            keyfile: 'rndc.key',
          )
        end
        it { is_expected.to contain_file('/usr/local/bin/rndc-helper') }

        it { is_expected.to contain_concat("#{expected_confdir}/acls.conf") }
        it { is_expected.to contain_concat("#{expected_confdir}/keys.conf") }
        it { is_expected.to contain_concat("#{expected_confdir}/views.conf") }
        it { is_expected.to contain_concat("#{expected_confdir}/servers.conf") }
        it { is_expected.to contain_concat("#{expected_confdir}/logging.conf") }
        it { is_expected.to contain_concat("#{expected_confdir}/view-mappings.txt") }
        it { is_expected.to contain_concat("#{expected_confdir}/domain-mappings.txt") }

        it do
          is_expected.to contain_concat__fragment('bind-logging-header').with(
            order: '00-header',
            target: "#{expected_confdir}/logging.conf",
            content: "logging {\n",
          )
        end
        it do
          is_expected.to contain_concat__fragment('bind-logging-footer').with(
            order: '99-footer',
            target: "#{expected_confdir}/logging.conf",
            content: "};\n",
          )
        end
        it { is_expected.to contain_file(expected_named_conf).that_requires('Package[bind]') }
        it { is_expected.to contain_file(expected_named_conf).that_notifies('Service[bind]') }
        it do
          is_expected.to contain_file('expected_named_conf')
            .with_content('%r{^options {$}')
            .without_content('%r{^\s+tkey-gssapi-credential}')
        end
        it do
          is_expected.to contain_service('bind').with({
                                                        ensure: 'running',
            name: expected_bind_service
                                                      })
        end
        case facts[:os]['family']
        when 'RedHat'
          it { is_expected.to contain_file(expected_default_zones_include) }
          it { is_expected.not_to contain_service('bind-no-chroot') }
        when 'Debian'
          it { is_expected.not_to contain_file(expected_default_zones_include) }
        end
      end
      context 'with chroot enabled' do
        let(:params) do
          {
            chroot: true,
            default_zones_include: '/etc/named/default-zones.conf'
          }
        end

        if !(facts[:os]['name'] == 'CentOS' && facts[:os]['release']['major'] == '7' ||
                facts[:os]['name'] == 'Debian' && facts[:os]['release']['major'].to_i >= 8)
          it { is_expected.to compile.and_raise_error(%r{Chroot for bind is not supported on your OS}) }
        else
          # Generic chroot part:
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('bind::keydir') }
          it { is_expected.to contain_class('bind::updater') }
          it { is_expected.to contain_class('bind') }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_package('bind').with({ ensure: 'latest', }) }
          it { is_expected.to contain_file('/usr/local/bin/dnssec-init') }
          it do
            is_expected.to contain_bind__key('rndc-key').with(
              algorithm: 'hmac-md5',
              secret_bits: '512',
              keydir: expected_confdir,
              keyfile: 'rndc.key',
            )
          end
          it { is_expected.to contain_file('/usr/local/bin/rndc-helper') }

          case facts[:os]['family']
          when 'RedHat'
            it { is_expected.to contain_file('/etc/named/default-zones.conf') }
          when 'Debian'
            it { is_expected.not_to contain_file(expected_default_zones_include) }
          end

          it { is_expected.to contain_concat("#{expected_confdir}/acls.conf") }
          it { is_expected.to contain_concat("#{expected_confdir}/keys.conf") }
          it { is_expected.to contain_concat("#{expected_confdir}/views.conf") }
          it { is_expected.to contain_concat("#{expected_confdir}/servers.conf") }
          it { is_expected.to contain_concat("#{expected_confdir}/logging.conf") }
          it { is_expected.to contain_concat("#{expected_confdir}/view-mappings.txt") }
          it { is_expected.to contain_concat("#{expected_confdir}/domain-mappings.txt") }

          it do
            is_expected.to contain_concat__fragment('bind-logging-header').with(
              order: '00-header',
              target: "#{expected_confdir}/logging.conf",
              content: "logging {\n",
            )
          end
          it do
            is_expected.to contain_concat__fragment('bind-logging-footer').with(
              order: '99-footer',
              target: "#{expected_confdir}/logging.conf",
              content: "};\n",
            )
          end
          it { is_expected.to contain_file(expected_named_conf).that_requires('Package[bind]') }
          it { is_expected.to contain_file(expected_named_conf).that_notifies('Service[bind]') }

          # OS family specific chroot setup:
          if facts[:os]['family'] == 'Debian'
            it { is_expected.to contain_class('bind::chroot::manual') }
          elsif facts[:os]['family'] == 'RedHat'
            it { is_expected.to contain_class('bind::chroot::package') }
          end
        end
      end
      context 'with tkey-* parameters' do
        let(:params) do
          {
            tkey_gssapi_credential: 'DNS/ds01.foobar.com',
            tkey_domain: 'foobar.com'
          }
        end

        it do
          is_expected.to contain_file(expected_named_conf)
            .with_content('%r{^options {$}')
            .with_content('%r{^\s+tkey-gssapi-credential "DNS/ds01.foobar.com";}')
            .with_content('%r{^\s+tkey-domain "foobar.com";$}')
        end
      end
    end
  end
end
