module WatCatcher
  class RackMiddleware
    class WatCatcher::Request
      attr_accessor :url, :method, :params, :headers, :session

      def initialize(url, method, params,  headers, session)
        @url = url
        @method = method
        @params = params
        @headers = headers
        @session = session
      end

      def filtered_parameters
        params
      end
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Exception => e
      if !env["wat_report_disabled"]
        begin
          user, request = nil
          if false && env["wat_report"]
            user = env["wat_report"][:user]
            request = env["wat_report"][:request]
          else
            rack_env = env
            rack_request = ::Rack::Request.new(env)
            params = rack_request.params rescue {}

            # Build the clean url (hide the port if it is obvious)
            url = "#{rack_request.scheme}://#{rack_request.host}"
            url << ":#{rack_request.port}" unless [80, 443].include?(rack_request.port)
            url << rack_request.fullpath

            headers = {}
            rack_env.each_pair do |key, value|
              if key.to_s.start_with?("HTTP_") || ["CONTENT_TYPE", "CONTENT_LENGTH"].include?(key)
                headers[key.upcase] = value
              end

            end
            request = WatCatcher::Request.new(url, rack_request.request_method, params.to_hash, headers, rack_env["rack.session"])
          end
        ensure
          WatCatcher::Report.new(e, user: user, request: request)
        end
      end
      raise
    end
  end
end
