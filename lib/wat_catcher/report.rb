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
      { wat: exception_description.merge(request_description).merge(worker_description) }
    end


    def exception_description
      {
        backtrace: exception.backtrace.to_a,
        message: exception.message,
        error_class: exception.class.to_s,
        app_env: ::Rails.env.to_s,
        app_name: ::Rails.application.class.parent_name
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
      Hash[*request.headers.select { |x| x.first !~ /\./ }.sort_by(&:first).flatten]
    end

    def worker_description
      return {} unless sidekiq
      {
        sidekiq_msg: sidekiq
      }
    end

  end
end

