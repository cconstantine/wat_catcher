require 'sidekiq'

module WatCatcher
 class SidekiqPoster
    include Sidekiq::Worker

     def perform(url, params)
      HTTPClient.post_content(url,
                              body: params.to_json,
                              header: {"Content-Type" => "application/json; charset=utf-8"})
    end
  end
end
