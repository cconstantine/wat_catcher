require 'active_support/concern'

module WatCatcher
  module CatcherOfWats
    extend ActiveSupport::Concern

    included do
      around_filter :catch_wats

      helper_method :wat_user
    end

    def wat_user
      current_user
    end

    def catch_wats(&block)
      block.call
    rescue Exception => e
      user = nil
      begin
        user = wat_user
      rescue;end
      WatCatcher::Report.new(e, user: user, request: request)
      raise
    end
  end
end
