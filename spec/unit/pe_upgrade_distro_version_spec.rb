require 'spec_helper'

describe 'pe_upgrade_distro_version fact' do
  subject { Facter.fact(:pe_upgrade_distro_version).value }
  after(:each) { Facter.clear }

  def stub_fact(fact, value)
    Facter.fact(fact).stubs(:value).returns value
  end


  distros = {
    'Debian' => {
      '6.0'   => '6',
      '6.0.7' => '6',
      '7.0'   => '7',
    },
    'Ubuntu'  => {
      '10.04'   => '10.04',
      '12.04'   => '12.04',
    },
    'RedHat' => {
      '5.9'  => '5',
      '6.4'  => '6',
    },
    'AIX'     => {
      '5.3'   => '5.3',
      '6.1'   => '6.1',
      '7.1'   => '7.1',
    },
    'Solaris' => {
      '5.10'  => '10',
    }
  }

  distros.each_pair do |distro, tests|
    tests.each_pair do |testcase, expected|
      describe "on #{distro} #{testcase}" do
        before(:each) do
          stub_fact :operatingsystem, distro
          stub_fact :operatingsystemrelease, testcase
        end
        it { should == expected }
      end
    end
  end
end
