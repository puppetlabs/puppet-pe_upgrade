# === [*version*]
#
# The version of PE to stage
#
# === [*installer*]
#
# The name of the installer, without an extension
#
# * example: 'puppet-enterprise-2.5.3-el-5'
#
# === [*download_dir*]
#
# The remote directory to download the installer from. Should not contain the
# version of PE as a directory component.
#
# * example: 'https://my.site.downloads/puppet-enterprise'
#
# === [*staging_root*]
#
# The full path where the installer should be downloaded to
#
# * example: '/opt/staging/pe_upgrade'
#

class pe_upgrade::staging(
  $version,
  $installer,
  $download_dir,
  $staging_root,
  $timeout,
) {

  include '::staging'

  $ext = $::pe_upgrade_extension
  $installer_pkg = regsubst("${installer}.${ext}", ':version', $version, 'G')
  $source_url    = regsubst("${download_dir}/${installer_pkg}", ':version', $version, 'G')

  #if $checksum {
  #  # Remove failed staging attempts. Nominally this should be in
  #  # the staging module.
  #  exec { "Remove installer tarball with invalid checksum":
  #    command => "rm ${staging_root}/${installer_tar}",
  #    path    => "/usr/bin:/bin",
  #    onlyif  => "test `md5sum ${installer_tar}` != ${checksum}",
  #    before  => Staging::File[$installer_tar],
  #  }
  #}

  staging::file { $installer_pkg:
    source  => $source_url,
    timeout => $timeout,
  }

  staging::extract { $installer_pkg:
    target  => $staging_root,
    require => Staging::File[$installer_pkg],
  }
}
