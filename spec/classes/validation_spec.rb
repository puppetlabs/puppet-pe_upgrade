require 'spec_helper'

describe 'pe_upgrade::validation' do
  let(:params) do
    {
      'allow_downgrade' => false,
      'upgrade_master'  => false,
      'version'         => '2.7.2',
    }
  end

  let(:facts) do
    {
      'pe_version'       => '2.6.1',
      'pe_major_version' => '2',
      'pe_minor_version' => '6',
      'pe_patch_version' => '1',
    }
  end

  describe 'when attempting a downgrade' do
    before { params['version'] = '2.5.3' }

    describe "and 'allow_downgrade' is not set" do
      it 'fails to compile' do
        expect { subject }.to raise_error Puppet::Error, /Refusing to downgrade/
      end
    end

    describe "and 'allow_downgrade' is set" do
      before { params['allow_downgrade'] = true }
      it "compiles" do
        expect { subject }.to_not raise_error
      end
    end
  end

  describe 'on windows' do
    before { facts['osfamily'] = 'Windows' }
    it 'fails to compile' do
      expect { subject }.to raise_error Puppet::Error, /not.*supported/
    end
  end

  describe 'on a puppet master' do
    before { facts['fact_is_puppetmaster'] = 'true' }

    describe "and 'upgrade_master' is not set" do
      it 'fails to compile' do
        expect { subject }.to raise_error Puppet::Error, /Refusing to upgrade Puppet master/
      end
    end

    describe "and 'upgrade_master' is not set" do
      before { params['upgrade_master'] = true }
      it "compiles" do
        expect { subject }.to_not raise_error
      end
    end
  end
end
