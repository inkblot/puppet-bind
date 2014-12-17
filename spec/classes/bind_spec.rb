# ex: syntax=ruby ts=2 sw=2 si et
require 'spec_helper'

describe 'bind' do
  let(:facts) { { :concat_basedir => '/wtf' } }

  context 'on Debian-derived systems' do
    let(:facts) { super().merge({ :osfamily => 'Debian' }) }
    
    it {
       should contain_package('bind').with({
        'ensure' => 'latest',
        'name' => 'bind9'
      })
    }

    it {
      should contain_service('bind').with({
        'ensure' => 'running',
        'name' => 'bind9'
      })
    }
  end

end
