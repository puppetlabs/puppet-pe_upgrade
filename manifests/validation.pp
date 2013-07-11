# This class exists to fail.
class pe_upgrade::validation(
  $version,
  $allow_downgrade,
  $upgrade_master,
) {

  if $::osfamily == 'Windows' {
    fail("osfamily 'Windows' is not currently supported")
  }

  if $::fact_is_puppetmaster == 'true' and ! $upgrade_master {
    fail("Refusing to upgrade Puppet master ${::clientcert} without 'upgrade_master' set")
  }

  # If someone really really wants to force a downgrade, I respect their
  # decisions and trust they understand the implication of their actions.
  if $pe_version and ! $allow_downgrade {
    $errmsg = "Refusing to downgrade from ${::pe_version} to ${version} without 'force_upgrade' set"
    $compare = versioncmp($pe_version, $version)

    if $compare == '1' {
      fail($errmsg)
    }
  }
}
