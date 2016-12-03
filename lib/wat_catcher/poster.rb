require 'httpclient'

module WatCatcher
 class Poster < ActiveJob::Base

     def perform(url, params)
      HTTPClient.post_content(url,
                              body: params.to_json,
                              header: {"Content-Type" => "application/json; charset=utf-8"})
    end
  end
end
