# ex: syntax=puppet si ts=4 sw=4 et

class bind::updater (
    $keydir = undef,
) {
    include params

    if $::bind::params::nsupdate_package {
        package { 'nsupdate':
            ensure => present,
            name   => $::bind::params::nsupdate_package,
        }
    }

    class { 'bind::keydir':
        keydir => $keydir,
    }
}
