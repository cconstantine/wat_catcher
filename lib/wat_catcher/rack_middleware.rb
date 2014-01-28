module WatCatcher
  class RackMiddleware

    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Exception => e
      if !env["wat_report_disabled"]
        user, request = nil
        if env["wat_report"]
          user = env["wat_report"][:user]
          request = env["wat_report"][:request]
        end

        WatCatcher::Report.new(e, user: user, request: request)
      end
      raise
    end
  end
end
