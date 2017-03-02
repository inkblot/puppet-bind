# ex: syntax=puppet si ts=4 sw=4 et

define bind::logging::channel (
    $destination     = 'file',
    $file_path       = $::bind::defaults::logdir,
    $file_name       = '',
    $syslog_facility = '',
    $severity        = '',
    $print_category  = true,
    $print_severity  = true,
    $print_time      = true,
) {
    unless member(['file', 'syslog', 'stderr', 'null'], $destination) {
        fail("Bind::logging::channel[${name}] has invalid destination: ${destination}. Must be one of: file syslog stderr null")
    }

    if $destination == 'file' {
        unless defined(File[$file_path]) {
            file { $file_path:
                ensure => directory,
                owner  => $::bind::bind_user,
                group  => $::bind::bind_group,
                mode   => '0640',
            }
        }

        if $file_name == '' {
            fail("Bind::logging::channel[${name}] must specify file_name when using file destination")
        }
    }

    if $destination == 'syslog' {
        unless member(['AUTH', 'AUTHPRIV', 'CRON', 'DAEMON', 'FTP', 'KERN', 'LOCAL0',
                'LOCAL1', 'LOCAL2', 'LOCAL3', 'LOCAL4', 'LOCAL5', 'LOCAL6', 'LOCAL7',
                'LPR', 'MAIL', 'NEWS', 'SYSLOG', 'USER', 'UUCP'], $syslog_facility) {
            file("Bind::logging::channell[${name}] has invalid syslog_facility: ${syslog_facility}.")
        }
    }

    unless $severity == '' or member(['critical', 'error', 'warning', 'notice', 'info', 'debug', 'dynamic'], $severity) {
        fail("Bind::logging::channel[${name}] has invalid severity: ${severity}")
    }

    concat::fragment { "bind-logging-channel-${name}":
        order   => "40-${name}",
        target  => "${::bind::confdir}/logging.conf",
        content => template('bind/logging_channel.erb'),
    }
}
