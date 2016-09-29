module WatCatcher
  class RackMiddleware
    class WatCatcher::Request
      attr_accessor :url, :method, :headers, :session

      def initialize(url, method, headers, session)
        @url = url
        @method = method
        @headers = headers
        @session = session
      end

      def filtered_parameters
        nil
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
          if env["wat_report"]
            user = env["wat_report"][:user]
            request = env["wat_report"][:request]
          else
            rack_env = env
            rack_request = ::Rack::Request.new(env)

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
            request = WatCatcher::Request.new(url, rack_request.request_method, headers, rack_request.session.to_hash)
          end
        ensure
          WatCatcher::Report.new(e, user: user, request: request)
        end
      end
      raise
    end
  end
end
