module WatCatcher
  class WatsController  < ApplicationController
    skip_before_filter :verify_authenticity_token, only: :create

    def create
      Report.new(nil, request: request)
      head :ok
    end
  end
end