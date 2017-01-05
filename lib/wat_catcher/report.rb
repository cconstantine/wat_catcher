module WatCatcher
  class Report
    attr_accessor :exception, :request, :sidekiq, :user

    def initialize(exception, user: nil, request: nil, sidekiq: nil)
      self.exception = exception
      self.request = request
      self.sidekiq = sidekiq
      self.user = user
      send_report
      log_report
      instrument_report unless metrics_disabled?
    end

    def send_report
      return if WatCatcher.configuration.disabled
      ::WatCatcher::Poster.perform_later("#{WatCatcher.configuration.host}/wats", params.as_json)
    end

    def log_report
      return if WatCatcher.configuration.disabled
      Rails.logger.error( "WatCatcher::error: " + base_description.tap {|x| x.delete(:rails_root) }.to_json )
    end

    def metrics_disabled?
      WatCatcher.configuration.metrics_disabled = true if WatCatcher.configuration.metrics_disabled.nil?
      WatCatcher.configuration.metrics_disabled
    end

    def metrics_reporter
      @reporter ||= ::WatCatcher::Metrics.new
      @reporter.host = WatCatcher.configuration.statsd_host
      @reporter.port = WatCatcher.configuration.statsd_port

      @reporter
    end

    def metrics_namespace
      "#{base_description[:app_name]}.#{base_description[:app_env]}".downcase
    end

    def instrument_report
      return if WatCatcher.configuration.disabled

      # increment graphite counter, ':' is used to seperate metric from metric value -- therefore, replace ':' with '_'
      #   e.g. kairos.staging.exceptions.NoMethodError.frequency is count of `NoMethodError`s during sample period (60s)
      #
      # for application-aggregated
      metrics_reporter.increment "#{metrics_namespace}.wat.#{exception_description[:error_class].gsub ':', '_'}.frequency"
      # for server-aggregated
      metrics_reporter.increment "#{metrics_namespace}.#{base_description[:hostname]}.wat.#{exception_description[:error_class].gsub ':', '_'}.frequency"

      # emit an event that an exception was raised
      metrics_reporter.set "#{metrics_namespace}.#{base_description[:hostname]}.wat.#{base_description[:error_class]}.occurance", base_description[:captured_at]
    end

    def params
      { wat: base_description
        .merge(user_description)
        .merge(exception_description)
        .merge(request_description)
        .merge(worker_description)
        .merge(param_exception_description) }
    end

    def param_exception_description
      return {} if exception || request.blank?
      request.params[:wat].merge(request_params: nil)
    end

    def base_description
      {
        app_env: ::Rails.env.to_s,
        app_name: ::Rails.application.class.parent_name,
        language: "ruby",
        captured_at: Time.zone.now,
        hostname: Socket.gethostname,
        rails_root: Rails.root.to_s
      }
    end

    def user_description
      u = nil
      begin
        u = user.as_json
      rescue; end
      { app_user: u }
    end

    def exception_description
      return {} unless exception
      {
        backtrace: exception.backtrace.to_a,
        message: exception.message,
        error_class: exception.class.to_s,
      }
    end

    def request_description
      return {} unless request
      request_params = request.filtered_parameters
      session = request.session.as_json
      page_url = request.url

      {
        page_url: page_url,
        request_headers: headers,
        request_params: request_params,
        session: session,
      }
    end

    def headers
      Hash[*request.headers.select { |x, y| y.instance_of? String }.sort_by(&:first).flatten]
    end

    def worker_description
      return {} unless sidekiq
      {
        sidekiq_msg: sidekiq
      }
    end

  end
end

