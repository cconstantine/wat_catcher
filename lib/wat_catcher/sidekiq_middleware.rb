module WatCatcher
  class SidekiqMiddleware
    def call(worker, msg, queue)
      begin
        yield
      rescue => excpt
        raise if thrown_by_watcatcher?(msg)
        WatCatcher::Report.new(excpt, sidekiq: msg)
        raise
      end
    end

    def thrown_by_watcatcher?(msg)
      msg["class"] =~ /WatCatcher/
    end
  end

end
