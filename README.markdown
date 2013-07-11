Puppet Enterprise Upgrade Module
================================

This module will upgrade Puppet Enterprise.

Usage
-----

### Downloading PE from puppetlabs.com

The simplest use of this class downloads the installer from the Puppet Labs
servers.

    include pe_upgrade

- - -

You can also locally host the downloads to conserve bandwidth and speed up
deployment time.

### Hosting the installer on the master

To cut down on size, the Puppet Enterprise installer is not included. You will
need to download your operating system specific installers and place the
installers in ${modulename}/files, for instance `site-files/files`.

You can use the following class definition to download the installer from your Puppet Master.

    class { 'pe_upgrade':
      version      => '2.7.0',
      answersfile  => "pe/answers/agent.txt.erb",
      download_dir => 'puppet:///site-files/pe/2.7.0',
      timeout      => '3600',
    }

### Hosting the installer on a web server

In this example, download 'puppet-enterprise-${version}-all.tar.gz' and place
it on your webserver.

    class { 'pe_upgrade':
      version      => '2.5.0',
      answersfile  => "pe/answers/agent.txt.erb",
      download_dir => 'http://site.downloads.local/pe/2.7.0',
      timeout      => '3600',
    }

Deploying the module from Puppet Dashboard
------------------------------------------

You can use Puppet Dashboard to configure this module. Since Puppet Dashboard
doesn't directly support parameterized classes, you can use global variables
to configure the module. See the data.pp class documentation for all respected
variables.

### Puppet Dashboard will show errors on pe_upgrade runs

The PE Upgrader restarts the puppet service as part of the upgrade process. This 
results in a TERM signal being sent to the puppet process executing the pe_upgrade
module. This will look something like this:

    notice executed successfully	/Stage[main]/Pe_upgrade/Staging::File[puppet-enterprise-2.5.3-all.tar.gz]/Exec[/opt/staging/pe_upgrade/puppet-enterprise-2.5.3-all.tar.gz]/returns	/etc/puppetlabs/puppet/modules/staging/manifests/file.pp	83	2012-08-08 20:29 UTC
    notice	executed successfully	/Stage[main]/Pe_upgrade/Staging::Extract[puppet-enterprise-2.5.3-all.tar.gz]/Exec[extract puppet-enterprise-2.5.3-all.tar.gz]/returns	/etc/puppetlabs/puppet/modules/staging/manifests/extract.pp	116	2012-08-08 20:30 UTC
    notice	executed successfully	/Stage[main]/Pe_upgrade/Exec[Validate answers]/returns	/etc/puppetlabs/puppet/modules/pe_upgrade/manifests/init.pp	137	2012-08-08 20:30 UTC
    notice	Caught TERM; calling stop	Puppet			2012-08-08 20:30 UTC

The _"failure"_ is expected and is not really a failure. Restarting the puppet service
can also leave unexecuted changes for the next run. So a _"full"_ upgrade may take two 
puppet runs.

Answers Templates
-----------------

A default answers file is available at templates/answers/default-agent.txt.erb.
It's recommended that you upgrade the master by hand, since that will provide
hiera for you, and since 2.5.0 has some new very site specific questions due
to the console auth component, it's not really possible to provide a generic
answers file.

Required modules
----------------

You will need hiera installed to use this module. Hiera has been added to PE
as of version 2.5.0; so you can upgrade your master to get it. If this isn't
an option, you can use the [puppet-hiera][puppet-hiera] module. You'll also
need a functioning hiera installation for this to work; you can use the
aforementioned hiera module to set up a basic configuration.

[puppet-hiera]: https://github.com/nanliu/puppet-hiera "Puppet module to install hiera"

The puppet-staging module is a prerequisite for this module. You can find it at
the following locations:

  * Puppet Forge: http://forge.puppetlabs.com/nanliu/staging
  * Github: https://github.com/nanliu/puppet-staging

See Also
--------

Please view the documentation in the enclosed manifests specific descriptions
and usage.

Getting Help
------------

If you have questions or concerns about this module, contact finch on #puppet
on Freenode, or email adrien@puppetlabs.com.

Caveats
-------

Due to the complexity of upgrading masters, using this module to upgrade a
master is possible but not supported out of the box; you'll have to supply
your own answers file.
