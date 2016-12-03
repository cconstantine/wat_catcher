require "wat_catcher/version"

require "wat_catcher/report"
require "wat_catcher/poster"
require "wat_catcher/wattle_helper"
require "wat_catcher/sidekiq_middleware"
require "wat_catcher/rack_middleware"

require "wat_catcher/railtie" if defined?(Rails::Railtie)


module WatCatcher
  class Configuration < OpenStruct
    def method_missing(method, *args)
      if method[-1] != "="
        ENV["wattle_#{method}".upcase] || super
      else
        super
      end
    end
  end

  class << self
    def configure(config_hash=nil)
      config_hash.each do |k, v|
        configuration.send("#{k}=", v)
      end if config_hash

      yield(configuration) if block_given?
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end

require "wat_catcher/engine"

