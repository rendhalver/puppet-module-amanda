class amanda::client (
  $remote_user    = undef,
  $server         = "backup.$::domain",
  $xinetd         = true,
  $dumptype       = 'default',
  $config         = 'daily',
  $server_ssh_key = undef,
  $backup_dirs    = undef,
  $exclude_dirs   = undef,
) {
  include amanda
  include amanda::params
  include concat::setup

  if $server_ssh_key != undef {
    amanda::ssh_authorized_key { $fqdn:
      key => $server_ssh_key,
    }
  }

  if $exclude_dirs != undef {
    amanda::target { $backup_dirs,
      ensure => present,
    }
  }

  if $exclude_dirs != undef {
    file { "${amanda::params::configs_directory}/exclude.list":
      ensure => file,
      owner => $amanda::params::user,
      group => $amanda::params::group,
      mode => 644,
    }
    amanda::exclude { $exclude_dirs:
      key => present,
    }
  }

  if $remote_user != undef {
    $remote_user_real = $remote_user
  } else {
    $remote_user_real = $amanda::params::user
  }

  # for systems that don't use xinetd, don't use xinetd
  if (("x$xinetd" == 'xtrue') and !$amanda::params::xinetd_unsupported) {
    realize(
      Xinetd::Service['amanda_tcp'],
      Xinetd::Service['amanda_udp'],
    )
  }

  if $amanda::params::generic_package {
    realize(Package['amanda'])
  } else {
    realize(Package['amanda/client'])
  }

  amanda::amandahosts { "amanda::client::amdump_${remote_user_real}@${server}":
    content => "${server} ${remote_user_real} amdump",
    order   => '00';
  }

  @@sshkey { "${fqdn}_amanda":
    ensure       => present,
    host_aliases => [$fqdn,$ipaddress],
    key          => $sshrsakey,
    type         => 'ssh-rsa',
    target       => "${amanda::params::homedir}/.ssh/known_hosts",
    tag          => 'backup',
  }

}
