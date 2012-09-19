# == Class: pe_upgrade
#
# This class will perform the upgrade of PE to the specified version.
#
# == Parameters
#
# If a parameter is not specified, it will default to the value in
# pe_upgrade::data. See that class for values
#
# [*version*]
#
# [*answersfile*]
#
# [*download_dir*]
#
# [*timeout*]
#
# == Examples
#
#   # Install from Puppet Labs servers with all defaults
#   include pe_upgrade
#
#
#   # More customized
#   class { 'pe_upgrade':
#     version      => '2.5.0',
#     answersfile  => "site/answers/${fqdn}-answers.txt",
#     download_dir => 'https://local.site.downloads/puppet-enterprise/2.5.0',
#     timeout      => '3600',
#  }
#
# == Caveats
#
# This has only been tested for PE versions 2.0.0 and greater.
#
# == Authors
#
# Adrien Thebo <adrien@puppetlabs.com>
#
# == Copyright
#
# Copyright 2012 Puppet Labs Inc.
#
# == License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class pe_upgrade(
  $download_dir = $pe_upgrade::data::download_dir,
  $version      = $pe_upgrade::data::version,
  $answersfile  = $pe_upgrade::data::answersfile,
  $checksum     = $pe_upgrade::data::checksum,
  $timeout      = $pe_upgrade::data::timeout
) inherits pe_upgrade::data {

  if ! $::fact_is_puppetmaster {
    if $version == $::pe_version {
      # This conditional is added to reduce the catalog size after the upgrade
      # has been performed.
    }
    else {
      require staging

      ############################################################################
      # Munge variables
      ############################################################################

      $installer_tar = "puppet-enterprise-${version}-all.tar.gz"
      $installer_dir = "puppet-enterprise-${version}-all"

      $source_url = "${download_dir}/${installer_tar}"

      $upgrader = "${staging::path}/pe_upgrade/${installer_dir}/puppet-enterprise-upgrader"

      $answersfile_dest = "${staging::path}/pe_upgrade/answers.txt"

      ############################################################################
      # Stage the installer and answers file
      ############################################################################

      if $checksum {
        # Remove failed staging attempts. Nominally this should be in
        # the staging module.
        exec { "rm ${installer_tar}":
          path   => "/usr/bin:/bin",
          onlyif => "test `md5sum ${installer_tar}` != ${checksum}",
          before => Staging::File[$installer_tar],
        }
      }

      staging::file { $installer_tar:
        source  => $source_url,
        timeout => $timeout,
      }

      staging::extract { $installer_tar:
        target  => "${staging::path}/pe_upgrade",
        require => Staging::File[$installer_tar],
      }

      file { $answersfile_dest:
        ensure  => present,
        content => template($answersfile),
        owner   => 0,
        group   => 0,
        require => File["${staging::path}/pe_upgrade"],
      }

      ############################################################################
      # Validate and perform upgrade
      ############################################################################

      exec { 'Validate answers':
        command   => "${upgrader} -n -a ${answersfile_dest}",
        path      => [
          '/usr/bin',
          '/bin',
          '/usr/local/bin',
          '/usr/sbin',
          '/sbin',
          '/usr/local/sbin'
        ],
        user      => 0,
        group     => 0,
        logoutput => on_failure,
        timeout   => $timeout,
        require   => Staging::Extract[$installer_tar],
      }

      exec { 'Run upgrade':
        command   => "${upgrader} -a ${answersfile_dest}",
        path      => [
          '/usr/bin',
          '/bin',
          '/usr/local/bin',
          '/usr/sbin',
          '/sbin',
          '/usr/local/sbin'
        ],
        user      => 0,
        group     => 0,
        logoutput => on_failure,
        timeout   => $timeout,
        require   => Exec['Validate answers'],
      }
    }
  }
}
