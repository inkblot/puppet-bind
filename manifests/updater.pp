# ex: syntax=puppet si ts=4 sw=4 et

class bind::updater (
    $keydir = undef,
) inherits bind::defaults {

    if $nsupdate_package {
        package { 'nsupdate':
            ensure => present,
            name   => $nsupdate_package,
        }
    }

    class { 'bind::keydir':
        keydir => $keydir,
    }
}
