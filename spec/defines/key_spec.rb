require 'spec_helper'

describe 'bind::key' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) do
        'include bind'
      end
      let (:facts) {facts}
      case facts[:os]['family']
        when 'Debian'
          expected_confdir = '/etc/bind'
          expected_group = 'bind'
        when 'RedHat'
          expected_confdir = '/etc/named'
          expected_group = 'named'
      end
      # Resource title:
      let(:title) { 'foobar-key' }
      context 'with defaults for all parameters' do
        it { should compile }
        it { should compile.with_all_deps }
        it do
          is_expected.to contain_file("#{expected_confdir}/keys/foobar-key").with(
            owner: 'root',
            group: expected_group,
            content: /^key foobar-key/
          )
        end
        it do
          is_expected.to contain_concat__fragment('bind-key-foobar-key').with(
            order: '10',
            target: "#{expected_confdir}/keys.conf",
            content: "include \"#{expected_confdir}\/keys\/foobar-key\";\n"
          )
        end
      end
    end
  end
end
