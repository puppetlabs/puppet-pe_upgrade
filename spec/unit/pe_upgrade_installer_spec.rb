require 'spec_helper'

describe 'pe_upgrade_codename fact' do
  subject { Facter.fact(:pe_upgrade_codename).value }
  after(:each) { Facter.clear }

  def stub_fact(fact, value)
    Facter.fact(fact).stubs(:value).returns value
  end

  describe 'on Debian based distro' do
    before { stub_fact :osfamily, 'Debian' }

    describe 'Vanilla Debian' do
      before { stub_fact :operatingsystem, 'Debian' }
      it { should == 'debian' }
    end

    describe 'Ubuntu' do
      before { stub_fact :operatingsystem, 'Ubuntu' }
      it { should == 'ubuntu' }
    end
  end

  [
    %w[RedHat el],
    %w[Suse sles],
    %w[Solaris solaris],
    %w[AIX aix],
  ].each do |(osfamily, codename)|
    describe "on osfamily #{osfamily}" do
      before { stub_fact :osfamily, osfamily }
      it { should == codename }
    end
  end
end
