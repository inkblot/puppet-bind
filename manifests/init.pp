class bind (
) {
	include bind::params

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

	concat { [
		"${bind::params::confdir}/acls.conf"
		"${bind::params::confdir}/views.conf"
		"${bind::params::confdir}/zones.conf"
		]:
		owner => $bind::params::bind_user,
		group => $bind::params::bind_group,
		mode  => '0644',
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

	concat::fragment { "named-zones-header":
		order   => '00',
		target  => "${bind::params::confdir}/zones.conf",
		content => "# This file is managed by puppet - changes will be lost\n",
	}
}
