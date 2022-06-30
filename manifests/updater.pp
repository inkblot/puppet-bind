# ex: syntax=puppet si ts=4 sw=4 et

class bind::updater (
  $keydir = undef,
) {
  if $bind::nsupdate_package {
    package { 'bind-tools':
      ensure => present,
      name   => $bind::nsupdate_package,
    }
  }
}
