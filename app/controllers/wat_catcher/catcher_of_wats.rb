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

    def disable_wat_report
      env["wat_report_disabled"] = true
    end

    def report_wat?
      !!(env["wat_report"].present? && !env["wat_report_disabled"])
    end

    def catch_wats(&block)
      block.call
    rescue Exception => e
      user = nil
      begin
        user = wat_user
      rescue;end
      env["wat_report"] = {
        request: request,
        user: user
      }
      disable_wat_report unless user_came_from_us
      disable_wat_report if access_denied?(e)
      raise
    end

    private

    def user_came_from_us
      request.referrer.present? || request_from_email?
    end

    def request_from_email?
      params[:utm_campaign].present? && params[:utm_medium] == "email"
    end

    def access_denied?(e)
      if defined?(CanCan::AccessDenied)
        e.is_a? CanCan::AccessDenied
      end
    end
  end
end
