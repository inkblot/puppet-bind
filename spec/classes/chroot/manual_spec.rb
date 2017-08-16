# ex: syntax=ruby ts=2 sw=2 si et
require 'spec_helper'

describe 'bind::chroot::manual' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      # Only applies to Debian Family for now:
      next unless facts[:os]['family'] == 'Debian'
      let (:facts) {facts}
      context "with defaults parameters" do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('bind::defaults') }
      end
    end
  end
end
