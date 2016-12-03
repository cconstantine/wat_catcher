require 'httpclient'

module WatCatcher
  class Poster < ActiveJob::Base

    def perform(url, params)
      HTTPClient.post_content(url,
                              body: params.to_json,
                              header: {"Content-Type" => "application/json; charset=utf-8"})
    rescue => excpt
      Rails.logger.error( "WatCatcher::Poster error thrown by wat_catcher!: #{excpt.inspect}" )

      retry_job(wait: 10)
    end
  end
end
