require 'spec_helper'

describe 'bind::zone' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      # Resource title:
      let(:title) { 'foobar-zone' }
      let(:params) do
        {
          zone_type: 'master'
        }
      end

      context 'with defaults for all parameters' do
        it { is_expected.to compile }
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
