# = Class: pe_upgrade::data
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
# === [*timeout*]
#
# The timeout in seconds for the download of the Puppet Enterprise installer.
#
# * global variable: pe_upgrade_timeout
# * default value: 3600 seconds
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
class pe_upgrade::data {
  if $::pe_upgrade_version { $version = $::pe_upgrade_version }
  else { $version = chomp(file('/opt/puppet/pe_version')) }

  if $::pe_upgrade_download_dir { $download_dir = $::pe_upgrade_download_dir }
  else { $download_dir = "https://pm.puppetlabs.com/puppet-enterprise/${version}" }

  if $::pe_upgrade_checksum { $checksum = $::pe_upgrade_checksum }
  else { $checksum = undef }

  if $::pe_upgrade_answersfile { $answersfile = $::pe_upgrade_answersfile }
  else { $answersfile = "pe_upgrade/answers/default-agent.txt.erb" }

  if $::pe_upgrade_timeout { $timeout = $::pe_upgrade_timeout }
  else { $timeout = '3600' }

  if $::pe_upgrade_mode { $mode = $::pe_upgrade_mode }
  else { $mode = 'upgrade' }

  if $::pe_upgrade_server { $server = $::pe_upgrade_server }
  else { $server = $::servername }

  if $::pe_upgrade_certname { $server = $::pe_upgrade_certname }
  else { $certname = $::clientcert }
}
