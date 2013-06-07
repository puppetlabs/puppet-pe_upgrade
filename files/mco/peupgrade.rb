require 'tmpdir'

module MCollective
  module Agent
    class Peupgrade<RPC::Agent
      metadata :name        => "peupgrade",
               :description => "Puppet Enterprise upgrader implemented in MCollective.",
               :author      => "Ben Ford",
               :license     => "GPLv2",
               :version     => "0.0.1",
               :url         => "http://github.com/binford2k/mco-peupgrade",
               :timeout     => 1800

      action "upgrade" do
        validate :version, /^[0-9]+\.[0-9]+\.[0-9]+$/
        version = request[:version]
        package = package(version)
        source  = "https://s3.amazonaws.com/pe-builds/released/#{version}/#{package}.tar.gz"

        pid = fork do
          daemonize!('peupgrade')

          Dir.mktmpdir("peupgrade-") do |dir|
            system("curl #{source} -o #{File.join(dir, "#{package}.tar.gz")}")
            system("tar -xzf #{File.join(dir, "#{package}.tar.gz")} -C #{dir}")
            Dir.chdir(File.join(dir, package))
            File.open('answers.txt', 'w') { |f| f.write(@answers) }
            # the output redirection is to catch errors before the installer starts logging
            system('./puppet-enterprise-upgrader -a answers.txt 2>&1 > peupgrade.lastrun.txt')
            Dir.glob('*.lastrun.*') { |f| FileUtils.cp(f, '/root') }
          end

          exit
        end

        Process.detach(pid)
        reply[:msg] = "Forked a daemon with PID #{pid} to upgrade Puppet Enterprise to #{package}."
      end

      action "uninstall" do
        validate :drop, :boolean
        validate :purge, :boolean

        # I think it's kind of funny that we have to download the full package to get the uninstaller
        version = '2.7.2' # hmm, no latest?
        package = package(version)
        source  = "https://s3.amazonaws.com/pe-builds/released/#{version}/#{package}.tar.gz"

        opts = ''
        opts << '-d ' if request[:drop]
        opts << '-p'  if request[:purge]

        pid = fork do
          daemonize!('peuninstall')

          Dir.mktmpdir('peupgrade-') do |dir|
            system("curl #{source} -o #{File.join(dir, "#{package}.tar.gz")}")
            system("tar -xzf #{File.join(dir, "#{package}.tar.gz")} -C #{dir}")
            Dir.chdir(File.join(dir, package))
            # the output redirection is to catch errors before the installer starts logging
            system("./puppet-enterprise-uninstaller -y #{opts} 2>&1 > peuninstall.lastrun.txt")
            Dir.glob('*.lastrun.*') { |f| FileUtils.cp(f, '/root') }
          end

          exit
        end

        Process.detach(pid)
        reply[:msg] = "Forked a daemon with PID #{pid} to uninstall Puppet Enterprise."
      end

      def startup_hook
        # answers taken from finch's pe_upgrade
        @answers = "PATH=/usr/local/bin:/opt/puppet/bin:/usr/bin:$PATH
        q_install=y
        q_puppet_cloud_install=n
        q_puppet_enterpriseconsole_install=n
        q_puppetagent_install=y
        q_puppetagent_server=`puppet agent --configprint server`
        q_puppetagent_certname=`puppet agent --configprint certname`
        q_puppetmaster_install=n
        q_rubydevelopment_install=n
        q_upgrade_install_wrapper_modules=n
        q_upgrade_installation=y
        q_upgrade_remove_mco_homedir=n
        q_vendor_packages_install=y
        q_puppet_symlinks_install=y
        q_continue_or_reenter_master_hostname=c\n"
      end

      def daemonize!(name)
        Process.setsid

        Dir.chdir '/'
        File.umask 0000

        STDIN.reopen '/dev/null'
        STDOUT.reopen '/dev/null', 'a'
        STDERR.reopen '/dev/null', 'a'

        $0 = name
      end

      def package(version)
        begin
          # This is yuk and a half. Do we really not have a better way to do this?
          # TODO: copy more of finch's logic in here. If these were facts....
          arch  = Facter.value('architecture')
          major = Facter.value('operatingsystemrelease').gsub(/\..*$/, '')

          case Facter.value('osfamily')
          when 'RedHat'
            os = 'el'
          when 'Debian'
            case Facter.value('operatingsystem')
            when 'Debian'
              os = 'debian'
            when 'Ubuntu'
              os = 'ubuntu'
            end
          when 'Suse'
            os = 'sles'
          when 'Solaris'
            os = 'solaris'
          end

          pkg = "puppet-enterprise-#{version}-#{os}-#{major}-#{arch}"
        rescue Exception
          # if anything goes wrong, just use the monolithic package
          pkg = "puppet-enterprise-#{version}-all"
        end

        return pkg
      end

    end
  end
end
