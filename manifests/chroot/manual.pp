# Chroot class for distribution without specific packaging
class bind::chroot::manual (
  $chroot_dir = $::bind::chroot_dir,
) {

  exec { 'make-bind-chroot-dir':
    command => "mkdir -p ${::bind::chroot_dir}",
    path    => ['/bin', '/usr/bin'],
    creates => $::bind::chroot_dir,
  }

  # Creating system dirs under chroot dir:
  file { [$::bind::chroot_dir,
          "${::bind::chroot_dir}/etc",
          "${::bind::chroot_dir}/dev",
          "${::bind::chroot_dir}/var",
          "${::bind::chroot_dir}/var/cache",
          "${::bind::chroot_dir}/var/run"]:
    ensure  => directory,
    mode    => '0661',
    require => Exec['make-bind-chroot-dir'],
  }

  file { ["${::bind::chroot_dir}/var/cache/bind", "${::bind::chroot_dir}/var/run/named"]:
    ensure  => directory,
    mode    => '0775',
    group   => $::bind::bind_group,
    require => Exec['make-bind-chroot-dir'],
  }

  exec { 'bind-chroot-mknod-dev-null':
    command => "mknod ${::bind::chroot_dir}/dev/null c 1 3",
    path    => ['/bin', '/usr/bin'],
    creates => "${::bind::chroot_dir}/dev/null",
  }

  -> exec { 'bind-chroot-mknod-dev-random':
    command => "mknod ${::bind::chroot_dir}/dev/random c 1 8",
    path    => ['/bin', '/usr/bin'],
    creates => "${::bind::chroot_dir}/dev/random",
  }

  -> exec { 'bind-chroot-mknod-dev-urandom':
    command => "mknod ${::bind::chroot_dir}/dev/urandom c 1 9",
    path    => ['/bin', '/usr/bin'],
    creates => "${::bind::chroot_dir}/dev/urandom",
  }

  -> file { [ "${::bind::chroot_dir}/dev/null",
            "${::bind::chroot_dir}/dev/random",
            "${::bind::chroot_dir}/dev/urandom"]:
    mode    => '0660',
  }

  exec { 'mv-etc-bind-into-jailed-etc':
      command => "mv ${::bind::confdir} ${::bind::chroot_dir}${::bind::confdir}",
      path    => ['/bin', '/usr/bin'],
      unless  => "test -d ${::bind::chroot_dir}${::bind::confdir}",
      require => [ Package['bind'], File["${::bind::chroot_dir}/etc"] ],
  }

  -> file { '/etc/bind':
      ensure => link,
      target => "${::bind::chroot_dir}${::bind::confdir}",
  }

}
