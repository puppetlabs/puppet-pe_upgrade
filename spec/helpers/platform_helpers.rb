module PlatformHelpers
  def self.platform_context(distro, architectures, releases, facts = {})

    architectures.each do |arch|
      releases.each do |release|
        platform_name = "#{distro} #{arch} #{release}"
        PlatformHelpers.platforms << platform_name

        shared_context platform_name do
          let(:facts) do
            {
              'osfamily'               => distro,
              'operatingsystem'        => distro,
              'operatingsystemrelease' => release,
              'hardwaremodel'          => arch,
              'pe_upgrade_installer'   => "puppet-enterprise-2.5.3-#{distro}-#{release}-#{arch}",
              'pe_upgrade_extension'   => 'tar.gz',
            }.merge facts
          end
        end
      end
    end
  end

  def self.platforms
    @platforms ||= []
  end

  def platforms
    PlatformHelpers.platforms
  end

  def on_all_platforms(&block)
    raise unless block

    platforms.each do |platform|
      context "on #{platform}" do
        instance_exec(platform, &block)
      end
    end
  end
end

RSpec.configure do |config|
  config.extend PlatformHelpers
end
