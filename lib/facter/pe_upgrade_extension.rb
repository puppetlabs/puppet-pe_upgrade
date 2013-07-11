Facter.add(:pe_upgrade_extension) do
  setcode do
    case Facter.value(:kernel)
    when 'windows'
      'msi'
    else
      'tar.gz'
    end
  end
end
