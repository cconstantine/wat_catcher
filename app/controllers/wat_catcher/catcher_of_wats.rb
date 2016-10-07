require 'active_support/concern'

module WatCatcher
  module CatcherOfWats
    extend ActiveSupport::Concern

    included do
      around_action :catch_wats

      helper_method :wat_user
    end

    def wat_user
      current_user
    end

    def disable_wat_report
      request.env["wat_report_disabled"] = true
    end

    def report_wat?
      !!(request.env["wat_report"].present? && !request.env["wat_report_disabled"])
    end

    def catch_wats(&block)
      block.call
    rescue Exception => e
      user = nil
      begin
        user = wat_user
      rescue;end
      request.env["wat_report"] = {
        request: request,
        user: user
      }
      raise
    end
  end
end
