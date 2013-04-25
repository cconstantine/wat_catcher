require "wat_catcher/version"

require 'wat_catcher/backgrounder'
require "wat_catcher/middleware"
require "wat_catcher/wat_helper"

require "wat_catcher/railtie" if defined?(Rails::Railtie)

module WatCatcher
  class << self
    def configure(config_hash=nil)
      config_hash.each do |k, v|
        configuration.send("#{k}=", v)
      end if config_hash

      yield(configuration) if block_given?
    end

    def configuration
      @configuration ||= OpenStruct.new
    end
  end
end