module WatCatcher
  class WatsController  < ActionController::Base
    skip_before_action :verify_authenticity_token, only: :create, raise: false

    include WatCatcher::CatcherOfWats

    def create
      Report.new(nil, request: request)
      head :ok
    end
  end
end
