Puppet::Parser::Functions.newfunction(:master_version, :type => :rvalue) do |args|
  version_file = '/opt/puppet/pe_version'
  if File.readable? version_file
    File.read(version_file).chomp
  end
end
