# ex: syntax=puppet si ts=4 sw=4 et

class bind (
    $forwarders                           = undef,
    $forward                              = undef,
    $dnssec                               = undef,
    $filter_ipv6                          = undef,
    $version                              = undef,
    $statistics_port                      = undef,
    $auth_nxdomain                        = undef,
    $include_default_zones                = true,
    $include_local                        = false,
    $tkey_gssapi_credential               = undef,
    $tkey_domain                          = undef,
    $chroot                               = false,
    $chroot_class                         = $::bind::defaults::chroot_class,
    $chroot_dir                           = $::bind::defaults::chroot_dir,
    # NOTE: we need to be able to override this parameter when declaring class,
    # especially when not using hiera (i.e. when using Foreman as ENC):
    $default_zones_include                = $::bind::defaults::default_zones_include,
) inherits bind::defaults {
    if $chroot and !$::bind::defaults::chroot_supported {
        fail('Chroot for bind is not supported on your OS')
    }
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

    if $chroot and $::bind::defaults::chroot_class {
        # When using a dedicated chroot class, service declaration is dedicated to this class
        class { $::bind::defaults::chroot_class : }
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
        file { $default_zones_include:
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

    # DO NOT declare a bind service when chrooting bind with bind::chroot::package class,
    # because it needs another dedicated chrooted-bind service (i.e. named-chroot on RHEL)
    # AND it also needs $::bind::defaults::bind_service being STOPPED and DISABLED.
    if !$chroot or ($chroot and $::bind::defaults::chroot_class == 'bind::chroot::manual') {
        service { 'bind':
            ensure     => running,
            name       => $::bind::defaults::bind_service,
            enable     => true,
            hasrestart => true,
            hasstatus  => true,
        }
    }
}
