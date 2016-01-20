# ex: syntax=puppet si ts=4 sw=4 et

class bind (
    $forwarders      = '',
    $dnssec          = true,
    $filter_ipv6     = false,
    $version         = '',
    $rndc            = undef,
    $statistics_port = undef,
    $auth_nxdomain   = false,
    $include_local   = false,
) inherits bind::defaults {

    File {
        ensure  => present,
        owner   => 'root',
        group   => $bind_group,
        mode    => '0644',
        require => Package['bind'],
        notify  => Service['bind'],
    }

    package{'bind-tools':
        ensure => latest,
        name   => $nsupdate_package,
        before => Package['bind'],
    }

    package { 'bind':
        ensure => latest,
        name   => $bind_package,
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

    if $rndc {
        # rndc only supports HMAC-MD5
        bind::key { 'rndc-key':
            algorithm   => 'hmac-md5',
            secret_bits => '512',
            keydir      => $confdir,
            keyfile     => 'rndc.key',
            include     => false,
        }
    }

    file { "${confdir}/zones":
        ensure  => directory,
        mode    => '2755',
    }

    file { $namedconf:
        content => template('bind/named.conf.erb'),
    }

    class { 'bind::keydir':
        keydir => "${confdir}/keys",
    }

    concat { [
        "${confdir}/acls.conf",
        "${confdir}/keys.conf",
        "${confdir}/views.conf",
        ]:
        owner   => 'root',
        group   => $bind_group,
        mode    => '0644',
        require => Package['bind'],
        notify  => Service['bind'],
    }

    concat::fragment { 'named-acls-header':
        order   => '00',
        target  => "${confdir}/acls.conf",
        content => "# This file is managed by puppet - changes will be lost\n",
    }

    concat::fragment { 'named-keys-header':
        order   => '00',
        target  => "${confdir}/keys.conf",
        content => "# This file is managed by puppet - changes will be lost\n",
    }

    concat::fragment { 'named-views-header':
        order   => '00',
        target  => "${confdir}/views.conf",
        content => "# This file is managed by puppet - changes will be lost\n",
    }

    service { 'bind':
        ensure     => running,
        name       => $bind_service,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
    }
}
