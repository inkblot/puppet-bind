# ex: syntax=puppet si ts=4 sw=4 et

define bind::zone (
    $zone_type,
    $domain          = '',
    $dynamic         = true,
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
    # where there is a zone, there is a server
    include bind
    $cachedir = $::bind::cachedir
    $_domain = pick($domain, $name)

    # dynamic implies master zone
    validate_bool(!($dynamic and $zone_type != 'master'))

    # masters implies slave/stub zone
    validate_bool(!($masters != '' and ! member(['slave', 'stub'], $zone_type)))

    # transfer_source implies slave/stub zone
    validate_bool(!($transfer_source != '' and ! member(['slave', 'stub'], $zone_type)))

    # allow_updates implies dynamic
    validate_bool(!($allow_update != '' and ! $dynamic))

    # dnssec implies dynamic zone
    validate_bool(!($dnssec and ! $dynamic))

    # key_directory implies dnssec
    validate_bool(!($key_directory != '' and ! $dnssec))

    # allow_notify implies slave/stub zone
    validate_bool(!($allow_notify != '' and ! member(['slave', 'stub'], $zone_type)))

    # forwarders implies forward zone
    validate_bool(!($forwarders != '' and $zone_type != 'forward'))

    # forward implies forward zone
    validate_bool(!($forward != '' and $zone_type != 'forward'))

    # source implies master/hint zone
    validate_bool(!($source != '' and ! member(['master', 'hint'], $zone_type)))

    $zone_file_mode = $zone_type ? {
        'master' => $dynamic ? {
            true  => 'init',
            false => 'managed',
        },
        'slave'  => 'allowed',
        'hint'   => 'managed',
        'stub'   => 'allowed',
        default  => 'absent',
    }

    if member(['init', 'managed', 'allowed'], $zone_file_mode) {
        file { "${cachedir}/${name}":
            ensure  => directory,
            owner   => $::bind::params::bind_user,
            group   => $::bind::params::bind_group,
            mode    => '0755',
            require => Package['bind'],
        }

        if member(['init', 'managed'], $zone_file_mode) {
            file { "${cachedir}/${name}/${_domain}":
                ensure  => present,
                owner   => $::bind::params::bind_user,
                group   => $::bind::params::bind_group,
                mode    => '0644',
                replace => ($zone_file_mode == 'managed'),
                source  => pick($source, 'puppet:///modules/bind/db.empty'),
                audit   => [ content ],
            }
        }
    } elsif $zone_file_mode == 'absent' {
        file { "${cachedir}/${name}":
            ensure => absent,
        }
    }

    if $dnssec {
        exec { "dnssec-keygen-${name}":
            command => "/usr/local/bin/dnssec-init '${cachedir}' '${name}'\
                '${_domain}' '${key_directory}'",
            cwd     => $cachedir,
            user    => $::bind::params::bind_user,
            creates => "${cachedir}/${name}/${_domain}.signed",
            timeout => 0, # crypto is hard
            require => [
                File['/usr/local/bin/dnssec-init'],
                File["${cachedir}/${name}/${_domain}"]
            ],
        }

        file { "${cachedir}/${name}/${_domain}.signed":
            owner => $::bind::params::bind_user,
            group => $::bind::params::bind_group,
            mode  => '0644',
            audit => [ content ],
        }
    }

    file { "${::bind::confdir}/zones/${name}.conf":
        ensure  => present,
        owner   => 'root',
        group   => $::bind::params::bind_group,
        mode    => '0644',
        content => template('bind/zone.conf.erb'),
        notify  => Service['bind'],
        require => Package['bind'],
    }

}
