class { 'bind':
  chroot                => true,
  # Note: this file MUST be into the /etc/named directory so the
  # RHEL7 specific setup-named-chroot.sh script will make it available into
  # the chroot.
  default_zones_include => '/etc/named/default-zones.conf',
  forwarders            => [
    '8.8.8.8',
    '8.8.4.4',
  ],
  dnssec                => true,
  version               => 'Controlled by Puppet',
}
