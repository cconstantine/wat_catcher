module WatCatcher
  class SidekiqMiddleware
    def call(worker, msg, queue)
      begin
        yield
      rescue => excpt
        return if msg["class"] == WatCatcher::SidekiqPoster.to_s
        p '******************* SETTING UP POSTING TO WATTLE *********************************'
        SidekiqPoster.perform_async(
            "#{WatCatcher.configuration.host}/wats",
            {
                wat: {
                    backtrace: excpt.backtrace.to_a,
                    message: excpt.message,
                    error_class: excpt.class.to_s,
                    sidekiq_msg: msg

                }
            })
      ensure
        raise
      end
    end
  end

end