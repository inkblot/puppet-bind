class bind (
	$confdir    = $bind::params::confdir,
	$cachedir   = $bind::params::cachedir,
	$forwarders = [],
) inherits bind::params {

	$auth_nxdomain = false

	package { $bind::params::bind_package:
		ensure => latest,
	}

	service { $bind::params::bind_service:
		ensure     => running,
		enable     => true,
		hasrestart => true,
		hasstatus  => true,
		require    => Package[$bind::params::bind_package],
	}
	
	file { $confdir:
		ensure  => directory,
		owner   => 'root',
		group   => $bind::params::bind_group,
		mode    => '2755',
		purge   => true,
		require => Package[$bind::params::bind_package],
	}

	file { "${confdir}/named.conf":
		ensure  => present,
		owner   => 'root',
		group   => $bind::params::bind_group,
		mode    => '0644',
		content => template('bind/named.conf.erb'),
		notify  => Service[$bind::params::bind_service],
	}

	file { [ "${confdir}/zones", "${confdir}/keys" ]:
		ensure => directory,
		owner  => 'root',
		group  => $bind::params::bind_group,
		mode   => '0755',
	}

	concat { [
		"${confdir}/acls.conf",
		"${confdir}/keys.conf",
		"${confdir}/views.conf",
		]:
		owner  => 'root',
		group  => $bind::params::bind_group,
		mode   => '0644',
		notify => Service[$bind::params::bind_service],
	}

	concat::fragment { "named-acls-header":
		order   => '00',
		target  => "${confdir}/acls.conf",
		content => "# This file is managed by puppet - changes will be lost\n",
	}

	concat::fragment { "named-keys-header":
		order   => '00',
		target  => "${confdir}/keys.conf",
		content => "# This file is managed by puppet - changes will be lost\n",
	}

	concat::fragment { "named-views-header":
		order   => '00',
		target  => "${confdir}/views.conf",
		content => "# This file is managed by puppet - changes will be lost\n",
	}
}
