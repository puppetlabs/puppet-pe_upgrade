# = Class: pe_upgrade::mco_agent
#
# This class manages a Puppet Enterprise upgrader implemented in MCollective.
#
# == Parameters
#
# If a parameter is not specified, it will default to the value in
# pe_upgrade::data. See that class for values
#
# [*mco_agent_dir*]
#
# * The directory to install the agent in.
#
# This agent currently has two functions:
#
# * Upgrade
#   * Can accept version parameter
# * Uninstall
#   * Accepts drop and purge options
#   * The Enterprise Console doesn't support booleans, so this must be run from the command line
#
# Usage
# =============
#
# ### Use Live Management
#
# 1. Choose a subset of nodes
# 2. Click the Advanced Tasks tab
# 3. Choose the `peupgrade` task
# 4. Choose the `upgrade` action
# 5. Optionally provide a version to upgrade to in `x.x.x` format.
# 6. Click run and go get a coffee.
#
# ### Command line example usage
#
# * `mco rpc peupgrade upgrade -F fact_is_puppetmaster=false -v`
# * `mco rpc peupgrade uninstall -F fact_is_puppetmaster=false drop=false purge=false -v`
#
# Limitations
# ============
#
# * It is currently not very configurable or robust.
#
# Contact
# =======
#
# * Author: Ben Ford
# * Email: ben.ford@puppetlabs.com
# * Twitter: @binford2k
# * IRC (Freenode): binford2k
#
class pe_upgrade::mco_agent (
  $mco_agent_dir = $pe_upgrade::data::mco_agent_dir,
) {
  file { "${mco_agent_dir}/peupgrade.rb":
    ensure => file,
    source => 'puppet::///modules/pe_upgrade/mco/peupgrade.rb',
  }
  file { "${mco_agent_dir}/peupgrade.ddl":
    ensure => file,
    source => 'puppet::///modules/pe_upgrade/mco/peupgrade.ddl',
  }
}
