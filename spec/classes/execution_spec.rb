require 'spec_helper'

describe 'pe_upgrade::execution', :type => :class do

  shared_examples_for "executing a Puppet Enterprise upgrade" do
    let(:installer) { 'puppet-enterprise-2.5.3' }
    let(:params) do
      {
        'version'       => '2.5.3',
        'certname'      => 'node-to-upgrade',
        'installer'     => 'puppet-enterprise-:version',
        'logfile'       => false,
        'mode'          => 'upgrade',
        'migrate_certs' => false,
        'server'        => 'server-node',
        'staging_root'  => '/opt/staging/pe_upgrade',
        'timeout'       => '300',
        'answersfile'   => 'pe_upgrade/answers/default-agent.txt.erb',
      }
    end

    it do
      should contain_file('/opt/staging/pe_upgrade/answers.txt').with({
        'ensure'  => 'present',
        'content' => /^q_puppetagent_server=server-node$.*^q_puppetagent_certname=node-to-upgrade$/m,
        'owner'   => '0',
        'group'   => '0',
      })
    end

    it do
      should contain_exec('Run upgrade').with({
        'command'   => /#{Regexp.new(installer)}.*puppet-enterprise-upgrader/,
        'user'      => '0',
        'group'     => '0',
        'logoutput' => 'on_failure',
        'timeout'   => '300',
      })
    end
  end

  on_all_platforms do |platform|
    it_behaves_like "executing a Puppet Enterprise upgrade"
  end
end
