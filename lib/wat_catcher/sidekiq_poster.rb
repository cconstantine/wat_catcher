require 'sidekiq'

module WatCatcher
  class SidekiqPoster
    include Sidekiq::Worker

    def self.report(exception, request: nil, sidekiq: nil)
      params = {
        wat: {
          backtrace: exception.backtrace.to_a,
          message: exception.message,
          error_class: exception.class.to_s,
          app_env: ::Rails.env.to_s,
          app_name: ::Rails.application.class.parent_name
        }
      }

      if request
        request_params = request.filtered_parameters
        session = request.session.as_json
        page_url = request.url

        params[:wat].merge!({
          page_url: page_url,
          request_params: request_params,
          session: session,
        })
      end

      if sidekiq
        params[:wat].merge!({
          sidekiq_msg: sidekiq
        })
      end

      ::WatCatcher::SidekiqPoster.perform_async("#{WatCatcher.configuration.host}/wats", params)
    end

    def perform(url, params)
      HTTPClient.post_content(url,
                              body: params["wat"].to_json,
                              header: {"Content-Type" => "application/json; charset=utf-8"})
    end
  end
end
