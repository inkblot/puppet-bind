# ex: syntax=puppet si ts=4 sw=4 et

define bind::zone (
    $zone_type,
    $domain          = '',
    $dynamic         = true,
    $masters         = '',
    $transfer_source = '',
    $allow_updates   = '',
    $update_policies = '',
    $allow_transfers = '',
    $dnssec          = false,
    $nsec3_salt      = '',
    $key_directory   = '',
    $ns_notify       = true,
    $also_notify     = '',
    $allow_notify    = '',
    $forwarders      = '',
    $forward         = '',
    $source          = '',
	$zonePath        = '', #add file already presend on system and don't manage zone file with puppet
) {
    # where there is a zone, there is a server
    include bind
    $cachedir = $::bind::cachedir
    $random_device = $::bind::random_device
    $_domain = pick($domain, $name)

    unless !($masters != '' and ! member(['slave', 'stub'], $zone_type)) {
        fail("masters may only be provided for bind::zone resources with zone_type 'slave' or 'stub'")
    }

    unless !($transfer_source != '' and ! member(['slave', 'stub'], $zone_type)) {
        fail("transfer_source may only be provided for bind::zone resources with zone_type 'slave' or 'stub'")
    }

    unless !($allow_updates != '' and ! $dynamic) {
        fail("allow_updates may only be provided for bind::zone resources with dynamic set to true")
    }

    unless !($dnssec and ! $dynamic) {
        fail("dnssec may only be true for bind::zone resources with dynamic set to true")
    }

    unless !($key_directory != '' and ! $dnssec) {
        fail("key_directory may only be provided for bind::zone resources with dnssec set to true")
    }

    unless !($allow_notify != '' and ! member(['slave', 'stub'], $zone_type)) {
        fail("allow_notify may only be provided for bind::zone resources with zone_type 'slave' or 'stub'")
    }

    unless !($forwarders != '' and $zone_type != 'forward') {
        fail("forwarders may only be provided for bind::zone resources with zone_type 'forward'")
    }

    unless !($forward != '' and $zone_type != 'forward') {
        fail("forward may only be provided for bind::zone resources with zone_type 'forward'")
    }

    unless !($source != '' and ! member(['master', 'hint'], $zone_type)) {
        fail("source may only be provided for bind::zone resources with zone_type 'master' or 'hint'")
    }

	if ($zonePath != '') {
		$zone_file_mode = 'static'
		$_zoneFilePath = $zonePath
	}
	else {
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
	}

    if member(['init', 'managed', 'allowed'], $zone_file_mode) {
	    $_zoneFilePath = "${cachedir}/${name}/${_domain}"
        file { "${cachedir}/${name}":
            ensure  => directory,
            owner   => $::bind::params::bind_user,
            group   => $::bind::params::bind_group,
            mode    => '0755',
            require => Package['bind'],
        }

        if member(['init', 'managed'], $zone_file_mode) {
            file { "$_zoneFilePath":
                ensure  => present,
                owner   => $::bind::params::bind_user,
                group   => $::bind::params::bind_group,
                mode    => '0644',
                replace => ($zone_file_mode == 'managed'),
                source  => pick($source, 'puppet:///modules/bind/db.empty'),
                audit   => [ content ],
            }
        }

        if $zone_file_mode == 'managed' {
            exec { "rndc reload ${_domain}":
                command     => "/usr/sbin/rndc reload ${_domain}",
                user        => $::bind::params::bind_user,
                refreshonly => true,
                require     => Service['bind'],
                subscribe   => File["$_zoneFilePath"],
            }
        }
    } elsif $zone_file_mode == 'absent' {
	    $_zoneFilePath = "${cachedir}/${name}"
        file { "$_zoneFilePath":
            ensure => absent,
        }
    }

    if $dnssec {
        exec { "dnssec-keygen-${name}":
            command => "/usr/local/bin/dnssec-init '${cachedir}' '${name}'\
                '${_domain}' '${key_directory}' '${random_device}' '${nsec3_salt}'",
            cwd     => $cachedir,
            user    => $::bind::params::bind_user,
            creates => "$_zoneFilePath",
            timeout => 0, # crypto is hard
            require => [
                File['/usr/local/bin/dnssec-init'],
                File["$_zoneFilePath"]
            ],
        }

        file { "$_zoneFilePath.signed":
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
