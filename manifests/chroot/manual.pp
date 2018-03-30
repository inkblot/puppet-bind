# Chroot class for distribution without specific packaging
class bind::chroot::manual(
    $chroot_dir            = $::bind::defaults::chroot_dir,
) inherits bind::defaults {
    exec { 'make-bind-chroot-dir':
      command => "mkdir -p ${::bind::defaults::chroot_dir}",
      path    => ['/bin', '/usr/bin'],
      creates => $::bind::defaults::chroot_dir,
    }
    # Creating system dirs under chroot dir:
    file { [$::bind::defaults::chroot_dir,
            "${::bind::defaults::chroot_dir}/etc",
            "${::bind::defaults::chroot_dir}/dev",
            "${::bind::defaults::chroot_dir}/var",
            "${::bind::defaults::chroot_dir}/var/cache",
            "${::bind::defaults::chroot_dir}/var/run"]:
      ensure  => directory,
      mode    => '0661',
      require => Exec['make-bind-chroot-dir'],
    }

    file { ["${::bind::defaults::chroot_dir}/var/cache/bind",
            "${::bind::defaults::chroot_dir}/var/run/named"]:
      ensure  => directory,
      mode    => '0775',
      group   => $::bind::defaults::bind_group,
      require => Exec['make-bind-chroot-dir'],
    }

    exec { 'bind-chroot-mknod-dev-null':
      command => "mknod ${::bind::defaults::chroot_dir}/dev/null c 1 3",
      path    => ['/bin', '/usr/bin'],
      creates => "${::bind::defaults::chroot_dir}/dev/null",
    }
    -> exec { 'bind-chroot-mknod-dev-random':
      command => "mknod ${::bind::defaults::chroot_dir}/dev/random c 1 8",
      path    => ['/bin', '/usr/bin'],
      creates => "${::bind::defaults::chroot_dir}/dev/random",
    }
    -> exec { 'bind-chroot-mknod-dev-urandom':
      command => "mknod ${::bind::defaults::chroot_dir}/dev/urandom c 1 9",
      path    => ['/bin', '/usr/bin'],
      creates => "${::bind::defaults::chroot_dir}/dev/urandom",
    }
    -> file { [ "${::bind::defaults::chroot_dir}/dev/null",
              "${::bind::defaults::chroot_dir}/dev/random",
              "${::bind::defaults::chroot_dir}/dev/urandom"]:
      mode    => '0660',
    }
    exec { 'mv-etc-bind-into-jailed-etc':
        command => "mv ${::bind::defaults::confdir} ${::bind::defaults::chroot_dir}${::bind::defaults::confdir}",
        path    => ['/bin', '/usr/bin'],
        unless  => "test -d ${::bind::defaults::chroot_dir}${::bind::defaults::confdir}",
        require => [ Package['bind'], File["${::bind::defaults::chroot_dir}/etc"] ],
    }
    -> file { '/etc/bind':
        ensure => link,
        target => "${::bind::defaults::chroot_dir}${::bind::defaults::confdir}",
    }
}
