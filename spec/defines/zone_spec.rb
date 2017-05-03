require 'spec_helper'

describe 'bind::zone' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let (:facts) {facts}
      # case facts[:os]['family']
      #   when 'Debian'
      #     expected_confdir = '/etc/bind'
      #     expected_group = 'bind'
      #   when 'RedHat'
      #     expected_confdir = '/etc/named'
      #     expected_group = 'named'
      # end
      # Resource title:
      let(:title) { 'foobar-zone' }
      let(:params) do
        {
          zone_type: 'master'
        }
      end
      context 'with defaults for all parameters' do
        it { should compile }
        it { should compile.with_all_deps }
      end
    end
  end
end
