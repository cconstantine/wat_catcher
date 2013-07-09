module WatCatcher
  class SidekiqMiddleware
    def call(worker, msg, queue)
      begin
        yield
      rescue => excpt
        raise if msg["class"] == WatCatcher::SidekiqPoster.to_s
        WatCatcher::SidekiqPoster.report(excpt, sidekiq: msg)
        raise
      end
    end
  end

end