# ex: syntax=puppet si ts=4 sw=4 et

class bind (
    $confdir    = $bind::params::confdir,
    $cachedir   = $bind::params::cachedir,
    $forwarders = '',
    $dnssec     = true,
    $version    = '',
) inherits bind::params {

    $auth_nxdomain = false

    package { $bind::params::bind_package:
        ensure => latest,
    }

    if $dnssec {
        file { '/usr/local/bin/dnssec-init':
            ensure => present,
            owner  => 'root',
            group  => 'root',
            mode   => '0755',
            source => 'puppet:///modules/bind/dnssec-init',
        }
    }

    service { $bind::params::bind_service:
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        require    => Package[$bind::params::bind_package],
    }

    File {
        ensure  => present,
        owner   => 'root',
        group   => $::bind::params::bind_group,
        mode    => 0644,
    }
    
    file { [ $confdir, "${confdir}/zones" ]:
        ensure  => directory,
        mode    => 2755,
        purge   => true,
        recurse => true,
        require => Package[$bind::params::bind_package],
    }

    file { "${confdir}/named.conf":
        content => template('bind/named.conf.erb'),
        notify  => Service[$bind::params::bind_service],
        require => Package[$bind::params::bind_package],
    }

    file { "${confdir}/keys":
        ensure  => directory,
        mode    => 0755,
        require => Package[$bind::params::bind_package],
    }

    file { "${confdir}/named.conf.local":
        replace => false,
        require => Package[$bind::params::bind_package],
    }

    concat { [
        "${confdir}/acls.conf",
        "${confdir}/keys.conf",
        "${confdir}/views.conf",
        ]:
        owner   => 'root',
        group   => $bind::params::bind_group,
        mode    => '0644',
        notify  => Service[$bind::params::bind_service],
        require => Package[$bind::params::bind_package],
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

    concat::fragment { "named-keys-rndc":
        order   => '99',
        target  => "${confdir}/keys.conf",
        content => "#include \"${confdir}/rndc.key\"\n",
    }

    concat::fragment { "named-views-header":
        order   => '00',
        target  => "${confdir}/views.conf",
        content => "# This file is managed by puppet - changes will be lost\n",
    }
}
