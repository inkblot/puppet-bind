require 'spec_helper'

describe 'bind::updater' do
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
  it { should compile }
  it { should compile.with_all_deps }
end
