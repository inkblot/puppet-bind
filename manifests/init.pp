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
	}
}
