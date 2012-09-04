class bind (
	$confdir = $bind::params::confdir,
) inherits bind::params {

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

	file { "${bind::params::confdir}/named.conf":
		ensure  => present,
		owner   => $bind::params::bind_user,
		group   => $bind::params::bind_group,
		mode    => '0644',
		content => template('bind/named.conf.erb'),
		notify  => Service[$bind::params::bind_service],
	}

	file { "${confdir}/zones":
		ensure => directory,
		owner  => $bind::params::bind_user,
		group  => $bind::params::bind_group,
		mode   => '0755',
	}

	concat { [
		"${bind::params::confdir}/acls.conf",
		"${bind::params::confdir}/views.conf",
		]:
		owner  => $bind::params::bind_user,
		group  => $bind::params::bind_group,
		mode   => '0644',
		notify => Service[$bind::params::bind_service],
	}

	concat::fragment { "named-acls-header":
		order   => '00',
		target  => "${bind::params::confdir}/acls.conf",
		content => "# This file is managed by puppet - changes will be lost\n",
	}

	concat::fragment { "named-views-header":
		order   => '00',
		target  => "${bind::params::confdir}/views.conf",
		content => "# This file is managed by puppet - changes will be lost\n",
	}
}
