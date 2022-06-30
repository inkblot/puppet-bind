# ex: syntax=puppet si ts=4 sw=4 et

class bind (
  String $version,
  Boolean $supported,
  Boolean $chroot_supported,
  String $chroot_class,
  String $confdir,
  String $default_zones_include,
  String $default_zones_source,
  String $namedconf,
  String $cachedir,
  String $logdir,
  String $bind_user,
  String $bind_group,
  String $bind_package,
  String $bind_service,
  String $nsupdate_package,
  String $managed_keys_directory,
  String $isc_bind_keys,
  String $random_device,
  String $forward,
  Boolean $dnssec,
  Boolean $filter_ipv6,
  Boolean $auth_nxdomain,
  Boolean $chroot = false,
  Boolean $include_default_zones = true,
  Boolean $include_local = false,
  Optional[Array] $forwarders = [],
  Optional[Integer] $statistics_port = undef,
  Optional[String] $chroot_dir = undef,
  Optional[String] $bind_chroot_package = undef,
  Optional[String] $bind_chroot_service = undef,
  Optional[String] $bind_chroot_dir = undef,
  Optional[String] $tkey_gssapi_credential = undef,
  Optional[String] $tkey_domain = undef,
) {
  include bind::updater

  unless $supported {
    fail('Platform is not supported by this version of bind module')
  }

  if $chroot and !$chroot_supported {
    fail('Running bind with chroot is not supported on your OS')
  }

  File {
    ensure  => present,
    owner   => 'root',
    group   => $bind_group,
    mode    => '0644',
    require => Package[$bind_package],
    notify  => Service[$bind_service],
  }

  package { 'bind':
    ensure => latest,
    name   => $bind_package,
  }

  if $chroot and $chroot_class {
    # When using a dedicated chroot class, service declaration is dedicated to this class
    class { $chroot_class : }
  }

  if $dnssec {
    file { '/usr/local/bin/dnssec-init':
      ensure => file,
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
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('bind/rndc-helper.erb'),
  }

  file { "${confdir}/zones":
    ensure => directory,
    mode   => '2755',
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
      "${confdir}/servers.conf",
      "${confdir}/logging.conf",
      "${confdir}/view-mappings.txt",
      "${confdir}/domain-mappings.txt",
    ]:
      owner   => 'root',
      group   => $bind_group,
      mode    => '0644',
      warn    => true,
      require => Package[$bind_package],
      notify  => Service[$bind_service],
  }

  concat::fragment { 'bind-logging-header':
    order   => '00-header',
    target  => "${confdir}/logging.conf",
    content => "logging {\n";
  }

  concat::fragment { 'bind-logging-footer':
    order   => '99-footer',
    target  => "${confdir}/logging.conf",
    content => "};\n";
  }

  # DO NOT declare a bind service when chrooting bind with bind::chroot::package class,
  # because it needs another dedicated chrooted-bind service (i.e. named-chroot on RHEL)
  # AND it also needs $::bind::defaults::bind_service being STOPPED and DISABLED.
  if !$chroot or ($chroot and $chroot_class == 'bind::chroot::manual') {
    service { $bind_service:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
    }
  }
}
