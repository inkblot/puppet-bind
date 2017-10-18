class bind::chroot::manual(
    $chroot_dir            = $::bind::defaults::chroot_dir,
) inherits bind::defaults {
    exec { 'mkdir-p-$chroot_dir':
      command => "mkdir -p ${::bind::defaults::chroot_dir}",
      path    => ['/bin', '/usr/bin'],
      unless  => "test -d ${::bind::defaults::chroot_dir}",
    }
    # Creating system dirs under chroot dir:
    file { ["${::bind::defaults::chroot_dir}",
            "${::bind::defaults::chroot_dir}/etc",
            "${::bind::defaults::chroot_dir}/dev",
            "${::bind::defaults::chroot_dir}/var",
            "${::bind::defaults::chroot_dir}/var/cache",
            "${::bind::defaults::chroot_dir}/var/run"]:
      ensure  => directory,
      mode    => '0660',
      require => Exec['mkdir-p-$chroot_dir'],
    }

    file { ["${::bind::defaults::chroot_dir}/var/cache/bind",
            "${::bind::defaults::chroot_dir}/var/run/named"]:
      ensure => directory,
      mode   => '0775',
      group  => $::bind::defaults::bind_group,
      require => Exec['mkdir-p-$chroot_dir'],
    }

    exec { 'mknod-dev-null':
      command => "mknod ${::bind::defaults::chroot_dir}/dev/null c 1 3",
      path    => ['/bin', '/usr/bin'],
      creates => "${::bind::defaults::chroot_dir}/dev/null",
    }
    exec { 'mknod-dev-random':
      command => "mknod ${::bind::defaults::chroot_dir}/dev/random c 1 8",
      path    => ['/bin', '/usr/bin'],
      creates => "${::bind::defaults::chroot_dir}/dev/random",
    }
    exec { 'mknod-dev-urandom':
      command => "mknod ${::bind::defaults::chroot_dir}/dev/urandom c 1 9",
      path    => ['/bin', '/usr/bin'],
      creates => "${::bind::defaults::chroot_dir}/dev/urandom",
    }
    file { [ "${::bind::defaults::chroot_dir}/dev/null",
             "${::bind::defaults::chroot_dir}/dev/random",
             "${::bind::defaults::chroot_dir}/dev/urandom"]:
      mode    => '0660',
      require => [ Exec['mknod-dev-null'], Exec['mknod-dev-random'], Exec['mknod-dev-urandom'] ],
    }
    exec { 'mv-etc-bind-into-jailed-etc':
        command => "mv ${::bind::defaults::confdir} ${::bind::defaults::chroot_dir}",
        path    => ['/bin', '/usr/bin'],
        unless  => "test -d ${::bind::defaults::chroot_dir}${::bind::defaults::confdir}",
        require => [ File["${::bind::defaults::chroot_dir}/etc"] ]
    }
    #-> file { '/etc/bind':
    #    ensure  => link,
    #    target  => "${::bind::defaults::chroot_dir}/${::bind::defaults::confdir}",
    #}
}
