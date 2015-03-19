# ex: syntax=puppet si ts=4 sw=4 et

define bind::zone (
    $zone_type,
    $ensure          = 'present',
    $domain          = '',
    $masters         = '',
    $transfer_source = '',
    $allow_updates   = '',
    $allow_transfers = '',
    $dnssec          = false,
    $key_directory   = '',
    $ns_notify       = true,
    $also_notify     = '',
    $allow_notify    = '',
    $forwarders      = '',
    $forward         = '',
    $source          = '',
) {
    $cachedir = $bind::cachedir

    if $domain == '' {
        $_domain = $name
    } else {
        $_domain = $domain
    }

    $has_zone_file = $zone_type ? {
        'master' => true,
        'slave'  => true,
        'hint'   => true,
        'stub'   => true,
        default  => false,
    }

    if $has_zone_file {
        if $zone_type == 'master' and $source != '' {
            $_source = $source
        } else {
            $_source = 'puppet:///modules/bind/db.empty'
        }

        file { "${cachedir}/${name}":
            ensure  => directory,
            owner   => $bind::params::bind_user,
            group   => $bind::params::bind_group,
            mode    => '0755',
            require => Package['bind'],
        }

        file { "${cachedir}/${name}/${_domain}":
            ensure  => present,
            owner   => $bind::params::bind_user,
            group   => $bind::params::bind_group,
            mode    => '0644',
            replace => false,
            source  => $_source,
            audit   => [ content ],
        }

        if $dnssec {
            exec { "dnssec-keygen-${name}":
                command => "/usr/local/bin/dnssec-init '${cachedir}' '${name}'\
                    '${_domain}' '${key_directory}'",
                cwd     => $cachedir,
                user    => $bind::params::bind_user,
                creates => "${cachedir}/${name}/${_domain}.signed",
                timeout => 0, # crypto is hard
                require => [
                    File['/usr/local/bin/dnssec-init'],
                    File["${cachedir}/${name}/${_domain}"]
                ],
            }

            file { "${cachedir}/${name}/${_domain}.signed":
                owner => $bind::params::bind_user,
                group => $bind::params::bind_group,
                mode  => '0644',
                audit => [ content ],
            }
        }
    }

    file { "${bind::confdir}/zones/${name}.conf":
        ensure  => $ensure,
        owner   => 'root',
        group   => $bind::params::bind_group,
        mode    => '0644',
        content => template('bind/zone.conf.erb'),
        notify  => Service['bind'],
        require => Package['bind'],
    }

    ini_setting { "${name}::include":
        ensure            => $ensure,
        path              => "${bind::confdir}/zones.conf",
        section           => '',
        key_val_separator => ' ',
        value             => "${bind::confdir}/zones/${name}.conf;",
        notify            => Service['bind'],
    }

}
