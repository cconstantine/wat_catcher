module WatCatcher
  class ClientWatsController
    def create
      Report.new(nil, request: request)
    end
  end
end