require 'spec_helper'

describe 'pe_upgrade', :type => :class do
  let(:facts) do
    {
      'servername'           => 'a server and such',
      'clientcert'           => 'wat',
      'pe_upgrade_installer' => 'puppet-enterprise-:version',
      'pe_upgrade_extension' => 'tar.gz',
      'pe_upgrade_version'   => '2.6.1',
    }
  end

  shared_examples_for 'orchestrating a Puppet Enterprise upgrade' do |platform|
    describe 'When PE is up to date' do
      before { facts['pe_version'] = '2.6.1' }

      describe 'and verbose is true' do
        let(:params) {{ 'verbose' => true }}
        it do
          should contain_notify("Upgrade status").with({
            'loglevel' => 'info'
          })
        end
      end

      describe 'and verbose is false' do
        it { should_not contain_notify("Upgrade status") }
      end

      it "purges the staging root of old installers" do
        should contain_file('/opt/staging/pe_upgrade')
      end
    end

    describe 'when an upgrade is required' do
      before { facts['pe_version'] = '2.0.3' }

      let(:params) do
        {
          'version' => '2.8.1',
        }
      end

      it do
        should contain_class('pe_upgrade::staging').with({
          'version'      => '2.8.1',
          'installer'    => 'puppet-enterprise-:version',
          'download_dir' => /pm\.puppetlabs\.com/,
          'staging_root' => %r[/opt/staging],
          'timeout'      => '3600',
        })
      end

      it do
        should contain_class('pe_upgrade::execution').with({
          'version'       => '2.8.1',
          'mode'          => 'upgrade',
          'migrate_certs' => 'false',
          'staging_root'  => %r[/opt/staging],
          'installer'     => 'puppet-enterprise-:version',
          'timeout'       => '3600',
          'logfile'       => 'false',
          'certname'      => 'wat',
          'server'        => 'a server and such',
          'answersfile'   => %r[pe_upgrade/answers],
        })
      end
    end
  end

  on_all_platforms do |platform|
    it_behaves_like 'orchestrating a Puppet Enterprise upgrade', platform
  end
end
