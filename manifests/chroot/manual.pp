# Chroot class for distribution without specific packaging
class bind::chroot::manual (
  $chroot_dir = $bind::chroot_dir,
) {
  exec { 'make-bind-chroot-dir':
    command => "mkdir -p ${facts['bind::chroot_dir']}",
    path    => ['/bin', '/usr/bin'],
    creates => $bind::chroot_dir,
  }

  # Creating system dirs under chroot dir:
  file { [$bind::chroot_dir,
      "${facts['bind::chroot_dir']}/etc",
      "${facts['bind::chroot_dir']}/dev",
      "${facts['bind::chroot_dir']}/var",
      "${facts['bind::chroot_dir']}/var/cache",
    "${facts['bind::chroot_dir']}/var/run"]:
      ensure  => directory,
      mode    => '0661',
      require => Exec['make-bind-chroot-dir'],
  }

  file { ["${facts['bind::chroot_dir']}/var/cache/bind", "${facts['bind::chroot_dir']}/var/run/named"]:
    ensure  => directory,
    mode    => '0775',
    group   => $bind::bind_group,
    require => Exec['make-bind-chroot-dir'],
  }

  exec { 'bind-chroot-mknod-dev-null':
    command => "mknod ${facts['bind::chroot_dir']}/dev/null c 1 3",
    path    => ['/bin', '/usr/bin'],
    creates => "${facts['bind::chroot_dir']}/dev/null",
  }

  -> exec { 'bind-chroot-mknod-dev-random':
    command => "mknod ${facts['bind::chroot_dir']}/dev/random c 1 8",
    path    => ['/bin', '/usr/bin'],
    creates => "${facts['bind::chroot_dir']}/dev/random",
  }

  -> exec { 'bind-chroot-mknod-dev-urandom':
    command => "mknod ${facts['bind::chroot_dir']}/dev/urandom c 1 9",
    path    => ['/bin', '/usr/bin'],
    creates => "${facts['bind::chroot_dir']}/dev/urandom",
  }

  -> file { ["${facts['bind::chroot_dir']}/dev/null",
      "${facts['bind::chroot_dir']}/dev/random",
    "${facts['bind::chroot_dir']}/dev/urandom"]:
      mode    => '0660',
  }

  exec { 'mv-etc-bind-into-jailed-etc':
    command => "mv ${facts['bind::confdir']} ${facts['bind::chroot_dir']}${facts['bind::confdir']}",
    path    => ['/bin', '/usr/bin'],
    unless  => "test -d ${facts['bind::chroot_dir']}${facts['bind::confdir']}",
    require => [Package['bind'], File["${facts['bind::chroot_dir']}/etc"]],
  }

  -> file { '/etc/bind':
    ensure => link,
    target => "${facts['bind::chroot_dir']}${facts['bind::confdir']}",
  }
}
