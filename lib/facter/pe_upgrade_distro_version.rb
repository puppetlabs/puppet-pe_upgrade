Facter.add(:pe_upgrade_distro_version) do
  confine :osfamily => 'RedHat'
  setcode { Facter.value(:operatingsystemrelease).sub(/^(\d+)\..*/, '\1') }
end

Facter.add(:pe_upgrade_distro_version) do
  confine :operatingsystem => 'Debian'
  setcode { Facter.value(:operatingsystemrelease).sub(/^(\d+)\..*/, '\1') }
end

Facter.add(:pe_upgrade_distro_version) do
  confine :operatingsystem => 'Ubuntu'
  setcode { Facter.value(:operatingsystemrelease) }
end

Facter.add(:pe_upgrade_distro_version) do
  confine :operatingsystem => 'Solaris'
  setcode { Facter.value(:operatingsystemrelease).sub(/\d\.(\d+)/, '\1') }
end

Facter.add(:pe_upgrade_distro_version) do
  confine :operatingsystem => 'AIX'
  setcode { Facter.value(:operatingsystemrelease) }
end
