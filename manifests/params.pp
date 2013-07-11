# = Class: pe_upgrade::params
#
# This class provides lookup of values for the upgrade process
#
# == Variable Use
#
# Each variable respects a global variable so that you can use this module
# from the console. If a global variable is not defined then the class falls
# back to a default value.
#
# === [*version*]
#
# The version of PE to install
#
# * global variable: pe_upgrade_version
# * default value: the PE version on the master
#
# === [*download_dir*]
#
# * global variable: pe_upgrade_download_dir
# * default value: https://pm.puppetlabs.com/puppet-enterprise/${version}
#
# === [*checksum*]
#
# The md5 checksum used to verify the installer download
#
# * global variable: pe_upgrade_checksum
# * default value: undef (no verification)
#
# === [*answersfile*]
#
# The node answersfile
#
# * global variable: pe_upgrade_answersfile
# * default value: pe_upgrade/answers/default-agent.txt.erb
#
# === [*mode*]
#
# Select whether to upgrade PE versions or upgrade Puppet open source to PE.
#
# * global variable: pe_upgrade_mode
# * default value: upgrade
#
# === [*migrate_certs*]
#
# If **mode** is set to install, this will optionally migrate the open source
# SSL directory to the PE installation.
#
# * global variable: pe_upgrade_migrate_certs
# * default value: false
#
# === [*server*]
#
# The server variable to use when templating the answersfile.
#
# * global variable: pe_upgrade_server
# * default value: $::server
#
# === [*certname*]
#
# The certname variable to use when templating the answersfile.
#
# * global variable: pe_upgrade_certname
# * default value: $::clientcert
#
# === [*timeout*]
#
# The timeout in seconds for the download of the Puppet Enterprise installer.
#
# * global variable: pe_upgrade_timeout
# * default value: 3600 seconds
#
# === [*allow_downgrade*]
#
# Force pe_upgrade to bypass downgrade checks
#
# By default, pe_upgrade will refuse to downgrade PE. If this is set to true
# the downgrade validation will be bypassed.
#
# * global variable: pe_upgrade_allow_downgrade
# * default value: false
#
# === [*upgrade_master*]
#
# By default, pe_upgrade will not try to upgrade Puppet masters, since they're
# somewhat sensitive. Enabling this # will bypass those checks. Use with caution.
#
# * global variable: pe_upgrade_upgrade_master
# * default value: false
#
# === [*verbose*]
#
# Generate warnings and notifications. If this is enabled then reports for
# nodes with this class might always report as changed.
#
# * global variable: pe_upgrade_verbose
# * default value: false
#
# === [*logfile*]
#
# If specified, writes the upgrade log to the given file.
#
# * global variable: pe_upgrade_logfile
# * default value: false
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
class pe_upgrade::params {

  $version      = pe_upgrade_pick($::pe_upgrade_version,      master_version())
  $download_dir = pe_upgrade_pick($::pe_upgrade_download_dir, "https://pm.puppetlabs.com/puppet-enterprise/:version")

  # @deprecated
  $checksum    = $::pe_upgrade_checksum

  $answersfile = pe_upgrade_pick($::pe_upgrade_answersfile, "pe_upgrade/answers/default-agent.txt.erb")
  $timeout     = pe_upgrade_pick($::pe_upgrade_timeout,     '3600')
  $mode        = pe_upgrade_pick($::pe_upgrade_mode,        'upgrade')
  $server      = pe_upgrade_pick($::pe_upgrade_server,      $::servername)
  $certname    = pe_upgrade_pick($::pe_upgrade_certname,    $::clientcert)

  $allow_downgrade = pe_upgrade_pick($::pe_upgrade_allow_downgrade, false)
  $upgrade_master  = pe_upgrade_pick($::pe_upgrade_upgrade_master,  false)
  $verbose         = pe_upgrade_pick($::pe_upgrade_verbose,         false)
  $logfile         = pe_upgrade_pick($::pe_upgrade_logfile,         false)
  $migrate_certs   = pe_upgrade_pick($::pe_upgrade_migrate_certs,   false)
}
