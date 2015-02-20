module WatCatcher
  class Report
    attr_accessor :exception, :request, :sidekiq, :user

    def initialize(exception, user: nil, request: nil, sidekiq: nil)
      self.exception = exception
      self.request = request
      self.sidekiq = sidekiq
      self.user = user
      send_report
    end

    def send_report
      return if WatCatcher.configuration.disabled
      ::WatCatcher::SidekiqPoster.perform_async("#{WatCatcher.configuration.host}/wats", params)
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
        hostname: Socket.gethostname
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

