# ex: syntax=puppet si ts=4 sw=4 et

class bind (
    $forwarders            = undef,
    $forward               = undef,
    $dnssec                = undef,
    $filter_ipv6           = undef,
    $version               = undef,
    $statistics_port       = undef,
    $auth_nxdomain         = undef,
    $include_default_zones = true,
    $include_local         = false,
    $options               = undef,
    $logging               = undef,
) inherits bind::defaults {

    if $logging {
      validate_hash($logging)

      if has_key($logging, 'channels') {
        validate_hash($logging['channels'])
      }
      else {
        fail('$logging should have a key named "channels"')
      }

      if has_key($logging, 'categories') {
        validate_hash($logging['categories'])
      }
      else {
        fail('$logging should have a key named "categories"')
      }
    }

    File {
        ensure  => present,
        owner   => 'root',
        group   => $bind_group,
        mode    => '0644',
        require => Package['bind'],
        notify  => Service['bind'],
    }

    include ::bind::updater

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

    # rndc only supports HMAC-MD5
    bind::key { 'rndc-key':
        algorithm   => 'hmac-md5',
        secret_bits => '512',
        keydir      => $confdir,
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

    file { "${confdir}/zones":
        ensure  => directory,
        mode    => '2755',
    }

    file { '/var/log/named':
      ensure  => directory,
      owner   => $bind_user,
      mode    => '0750',
      seltype => 'named_log_t',
    }
    
    file { $namedconf:
        content => template('bind/named.conf.erb'),
    }

    if $include_default_zones and $default_zones_source {
        file { $default_zones_include:
            source => $default_zones_source,
        }
    }

    class { 'bind::keydir':
        keydir => "${confdir}/keys",
    }

    concat { [
        "${confdir}/acls.conf",
        "${confdir}/keys.conf",
        "${confdir}/views.conf",
        "${confdir}/view-mappings.txt",
        "${confdir}/domain-mappings.txt",
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
