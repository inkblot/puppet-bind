# ex: syntax=puppet si ts=4 sw=4 et

class bind (
    $forwarders             = undef,
    $forward                = undef,
    $dnssec                 = undef,
    $filter_ipv6            = undef,
    $version                = undef,
    $statistics_port        = undef,
    $auth_nxdomain          = undef,
    $include_default_zones  = true,
    $include_local          = false,
    $tkey_gssapi_credential = undef,
    $tkey_domain            = undef,
) inherits bind::defaults {

    File {
        ensure  => present,
        owner   => 'root',
        group   => $::bind::defaults::bind_group,
        mode    => '0644',
        require => Package['bind'],
        notify  => Service['bind'],
    }

    include ::bind::updater

    package { 'bind':
        ensure => latest,
        name   => $::bind::defaults::bind_package,
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

    # rndc only supports HMAC-MD5
    bind::key { 'rndc-key':
        algorithm   => 'hmac-md5',
        secret_bits => '512',
        keydir      => $bind::defaults::confdir,
        keyfile     => 'rndc.key',
        include     => false,
    }

    file { '/usr/local/bin/rndc-helper':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('bind/rndc-helper.erb'),
    }

    file { "${::bind::defaults::confdir}/zones":
        ensure => directory,
        mode   => '2755',
    }

    file { $::bind::defaults::namedconf:
        content => template('bind/named.conf.erb'),
    }

    if $include_default_zones and $::bind::defaults::default_zones_source {
        file { $::bind::defaults::default_zones_include:
            source => $::bind::defaults::default_zones_source,
        }
    }

    class { '::bind::keydir':
        keydir => "${::bind::defaults::confdir}/keys",
    }

    concat { [
        "${::bind::defaults::confdir}/acls.conf",
        "${::bind::defaults::confdir}/keys.conf",
        "${::bind::defaults::confdir}/views.conf",
        "${::bind::defaults::confdir}/servers.conf",
        "${::bind::defaults::confdir}/logging.conf",
        "${::bind::defaults::confdir}/view-mappings.txt",
        "${::bind::defaults::confdir}/domain-mappings.txt",
        ]:
        owner   => 'root',
        group   => $::bind::defaults::bind_group,
        mode    => '0644',
        warn    => true,
        require => Package['bind'],
        notify  => Service['bind'],
    }

    concat::fragment { 'bind-logging-header':
        order   => '00-header',
        target  => "${::bind::defaults::confdir}/logging.conf",
        content => "logging {\n";
    }

    concat::fragment { 'bind-logging-footer':
        order   => '99-footer',
        target  => "${::bind::defaults::confdir}/logging.conf",
        content => "};\n";
    }

    service { 'bind':
        ensure     => running,
        name       => $::bind::defaults::bind_service,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
    }
}
