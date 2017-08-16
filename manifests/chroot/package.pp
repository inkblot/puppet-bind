class bind::chroot::package(
    $chroot_dir            = $::bind::defaults::chroot_dir,
) inherits bind::defaults {
    package { 'bind-chroot':
      ensure  => latest,
    }
    service { 'bind':
        ensure     => running,
        name       => 'named-chroot',
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
    }
    # On RHEL Family, there is a dedicated service named-chroot and we need
    # to stop/disable 'named' service:
    service { 'bind-without-chroot':
        ensure => stopped,
        name   => $::bind::defaults::bind_service,
        enable => false,
    }
}
