module WatCatcher
  class Report
    attr_accessor :exception, :request, :sidekiq

    def initialize(exception, request: nil, sidekiq: nil)
      self.exception = exception
      self.request = request
      self.sidekiq = sidekiq
      send_report
    end

    def send_report
      ::WatCatcher::SidekiqPoster.perform_async("#{WatCatcher.configuration.host}/wats", params)
    end

    def params
      { wat: base_description.merge(exception_description).merge(request_description).merge(worker_description).merge(param_exception_description) }
    end

    def param_exception_description
      return {} if exception || request.blank?
      wat_params = request.params[:wat]
      {
        message: wat_params[:message],
        backtrace: wat_params[:backtrace],
        page_url: wat_params[:page_url],
        request_params: nil
      }
    end

    def base_description
      {
        app_env: ::Rails.env.to_s,
        app_name: ::Rails.application.class.parent_name
      }
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

