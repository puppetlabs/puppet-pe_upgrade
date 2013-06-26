class pe_upgrade::execution(
  $certname,
  $installer,
  $version,
  $logfile,
  $mode,
  $migrate_certs,
  $server,
  $staging_root,
  $timeout,
  $answersfile,
) {

  $bin = $mode ? {
    'install' => 'puppet-enterprise-installer',
    default   => 'puppet-enterprise-upgrader',
  }

  if $logfile { $log_directive = "-l ${logfile}" }
  else        { $log_directive = "" }

  $answersfile_dest = "${staging_root}/answers.txt"

  $cmd = regsubst("${staging_root}/${installer}/${bin}", ':version', $version, 'G')
  $validate_cmd = "${cmd} -n -a ${answersfile_dest}"
  $run_cmd      = "${cmd} ${log_directive} -a ${answersfile_dest}"

  $exec_paths = [
    '/usr/bin',
    '/bin',
    '/usr/local/bin',
    '/usr/sbin',
    '/sbin',
    '/usr/local/sbin'
  ]

  file { $answersfile_dest:
    ensure  => present,
    content => template($answersfile),
    owner   => 0,
    group   => 0,
  }

  #exec { 'Validate answers':
  #  command   => $validate_cmd,
  #  path      => $exec_paths,
  #  user      => 0,
  #  group     => 0,
  #  logoutput => on_failure,
  #  timeout   => $timeout,
  #  require   => File[$answersfile_dest],
  #}

  exec { 'Run upgrade':
    command   => $run_cmd,
    path      => $exec_paths,
    user      => 0,
    group     => 0,
    logoutput => on_failure,
    timeout   => $timeout,
  }

  ############################################################################
  # If running in install mode, then shut down Puppet Open Source after install
  # Don't actually remove it. Let the user define that strategy
  ############################################################################
  if $mode == 'install' {
    service { 'puppet':
      ensure  => stopped,
      enable  => false,
      require => Exec['Run upgrade'],
    }

    if $migrate_certs {
      file { ['/etc/puppetlabs', '/etc/puppetlabs/puppet']:
        ensure  => directory,
        owner   => 0,
        group   => 0,
        mode    => '0700',
        before  => Exec['Run upgrade'],
      }

      # This is done over a recursive file definition because the file definition
      # will display diffs and thus leak sensitive information.
      exec { '/bin/cp --recursive --force /var/lib/puppet/ssl /etc/puppetlabs/puppet/':
        user      => 0,
        group     => 0,
        logoutput => on_failure,
        require   => Exec['Run upgrade'],
        before    => Service['puppet'],
      }
    }
  }
}
