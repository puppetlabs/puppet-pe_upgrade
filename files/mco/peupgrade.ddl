metadata :name        => "peupgrade",
         :description => "Puppet Enterprise upgrader implemented in MCollective.",
         :author      => "Ben Ford",
         :license     => "GPLv2",
         :version     => "0.0.1",
         :url         => "http://github.com/binford2k/mco-peupgrade",
         :timeout     => 30

action "upgrade", :description => "Upgrade Puppet Enterprise to a newer version" do
   input :version,
         :prompt      => "Version",
         :description => "What version should this upgrade to?",
         :type        => :string,
         :validation  => '^[0-9]+\.[0-9]+\.[0-9]+$',
         :optional    => true

   output :msg,
          :description => "Completion message",
          :display_as  => "Message"
end

action "uninstall", :description => "Remove Puppet Enterprise from a node. This does not work from the console." do
   input :drop,
         :prompt      => "Drop tables",
         :description => "Drop all Puppet Enterprise tables from the database",
         :type        => :boolean,
         :optional    => true

   input :purge,
         :prompt      => "Purge config",
         :description => "Purge configuration files",
         :type        => :boolean,
         :optional    => true

   output :msg,
          :description => "Completion message",
          :display_as  => "Message"
end