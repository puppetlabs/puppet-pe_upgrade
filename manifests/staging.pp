class pe_upgrade::staging($timeout) {

  include pe_upgrade
  include staging

  # These variables are not passed as parameters because they have to remain
  # constant across classes and should not be tuned. Private variables, if you
  # will.
  $installer_tar = $::pe_upgrade::installer_tar
  $version       = $::pe_upgrade::version
  $checksum      = $::pe_upgrade::checksum
  $staging_root  = $::pe_upgrade::staging_root

  $source_url    = "${pe_upgrade::download_dir}/${installer_tar}"

  if $checksum {
    # Remove failed staging attempts. Nominally this should be in
    # the staging module.
    exec { "Remove installer tarball with invalid checksum":
      command => "rm ${staging_root}/${installer_tar}",
      path    => "/usr/bin:/bin",
      onlyif  => "test `md5sum ${installer_tar}` != ${checksum}",
      before  => Staging::File[$installer_tar],
    }
  }

  staging::file { $installer_tar:
    source  => $source_url,
    timeout => $timeout,
  }

  staging::extract { $installer_tar:
    target  => $staging_root,
    require => Staging::File[$installer_tar],
  }
}
