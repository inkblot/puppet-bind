# ex: syntax=puppet si ts=4 sw=4 et

class bind::updater (
    $nsupdate_package,
    $keydir = 
) inherits bind::params {
    package {'nsupdate':
        name => $nsupdate_package,
        ensure => present,
    }

    class { 'bind::keydir':
        keydir => $keydir,
    }
}
