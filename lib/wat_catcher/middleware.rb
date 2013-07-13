module WatCatcher
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Exception => exception
      Report.new(exception, request: env["action_controller.instance"].request)
      raise
    end
  end


end
