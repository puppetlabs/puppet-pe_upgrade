require 'spec_helper'

describe 'pe_upgrade::staging', :type => :class do

  shared_examples_for 'staging the Puppet Enterprise installer package' do |context|
    include_context context

    let(:installer) { facts['pe_upgrade_installer'] }

    let(:params) do
      {
        'installer'    => installer,
        'version'      => '2.5.3',
        'download_dir' => 'https://download.dir',
        'timeout'      => '300',
        'staging_root' => '/opt/staging/pe_upgrade',
      }
    end


    it do
      should contain_staging__file("#{installer}.tar.gz").with({
        'source'  => "https://download.dir/#{installer}.tar.gz",
        'timeout' => '300',
      })
    end

    it do
      should contain_staging__extract("#{installer}.tar.gz").with({
        'target' => '/opt/staging/pe_upgrade',
      })
    end
  end

  on_all_platforms do |platform|
    it_behaves_like 'staging the Puppet Enterprise installer package', platform
  end
end
