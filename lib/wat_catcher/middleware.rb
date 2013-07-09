module WatCatcher
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue
      excpt = $!
      request = env["action_controller.instance"].request
      params = request.filtered_parameters
      session = request.session.as_json
      page_url = request.url

      # Build the clean url (hide the port if it is obvious)
      url = "#{request.scheme}://#{request.host}"
      url << ":#{request.port}" unless [80, 443].include?(request.port)
      url << request.fullpath

      ::WatCatcher::SidekiqPoster.perform_async(
        "#{WatCatcher.configuration.host}/wats",
        {
            wat: {
                page_url: page_url,
                request_params: params,
                session: session,
                backtrace: excpt.backtrace.to_a,
                message: excpt.message,
                error_class: excpt.class.to_s
            }
        })
      raise
    end
  end


end