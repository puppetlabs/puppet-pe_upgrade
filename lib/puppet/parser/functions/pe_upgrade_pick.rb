Puppet::Parser::Functions.newfunction(:pe_upgrade_pick, :type => :rvalue, :doc => <<-EOS

Vendored copy of the `pick` function.

See https://github.com/puppetlabs/puppetlabs-stdlib/blob/2.6.0/lib/puppet/parser/functions/pick.rb

EOS
) do |args|
   args = args.compact
   args.delete(:undef)
   args.delete(:undefined)
   args.delete("")
   if args[0].to_s.empty? then
     fail "Must provide non empty value."
   else
     return args[0]
   end
end
