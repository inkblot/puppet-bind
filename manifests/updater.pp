# ex: syntax=puppet si ts=4 sw=4 et

class bind::updater (
    $nsupdate_package = $::bind::params::nsupdate_package,
    $keydir           = "${::bind::params::confdir}/keys",
) inherits bind::params {
    package {'nsupdate':
        ensure => present,
        name   => $nsupdate_package,
    }

    file { $::bind::params::confdir:
        ensure => directory,
    }

    class { 'bind::keydir':
        keydir => $keydir,
    }
}
