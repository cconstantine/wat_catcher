require 'sidekiq'

module WatCatcher
  class SidekiqPoster
    include Sidekiq::Worker

    def perform(url, params)
      p '******************* POSTING TO WATTLE *********************************'
      HTTPClient.post_content(url,
                              body: params["wat"].merge({"app_env" => ::Rails.env.to_s}).to_json,
                              header: {"Content-Type" => "application/json; charset=utf-8"})
    end
  end
end
