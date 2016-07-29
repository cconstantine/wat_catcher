module WatCatcher
  class BugsnagController < ActionController::Base
    skip_before_filter :verify_authenticity_token, only: :get, raise: false
    include WatCatcher::CatcherOfWats

    def show
      request.params[:wat] = HashWithIndifferentAccess.new
      request.params[:wat][:backtrace] = stacktrace
      request.params[:wat][:message] = params[:message]
      request.params[:wat][:page_url] = params[:url]
      request.params[:wat][:language] = 'javascript'

      begin
        user = JSON.parse(params[:user])
      rescue JSON::ParserError;end
    ensure
      @report = Report.new(nil, user: user, request: request)
      response.headers['Content-Type'] = "image/png; charset=utf-8"
      head :ok
    end

    def stacktrace
      params[:stacktrace].split("\n")[1..-1]
    end
  end
end
