module WatCatcher
  class Railtie < ::Rails::Railtie

    config.before_initialize do
      # Configure bugsnag rails defaults
      WatCatcher.configure do |config|
        config.logger = ::Rails.logger
        config.release_stage = ::Rails.env.to_s
        config.project_root = ::Rails.root.to_s
      end

      # Auto-load configuration settings from config/bugsnag.yml if it exists
      config_file = ::Rails.root.join("config", "wat_catcher.yml")
      config = YAML.load_file(config_file) if File.exists?(config_file)
      WatCatcher.configure(config[::Rails.env] ? config[::Rails.env] : config) if config
    end
  end

end