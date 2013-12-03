module WatCatcher
  class WatsController  < ActionController::Base
    skip_before_filter :verify_authenticity_token, only: :create

    include WatCatcher::CatcherOfWats

    def create
      Report.new(nil, request: request)
      head :ok
    end
  end
end