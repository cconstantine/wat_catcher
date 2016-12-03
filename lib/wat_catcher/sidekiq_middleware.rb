module WatCatcher
  class SidekiqMiddleware
    def call(worker, msg, queue)
      begin
        yield
      rescue => excpt
        u = nil
        begin
          if worker.class == Sidekiq::Extensions::DelayedClass
            (worker,method_name,args) = YAML.load(msg["args"][0])
          end
          if worker.respond_to?(:wat_user) && worker.method(:wat_user).arity == msg["args"].length
            u = worker.wat_user(*msg["args"])
          else
            u = { id: "jid_#{msg["jid"]}", jid: msg["jid"] }
          end

        rescue
        end

        WatCatcher::Report.new(excpt, user: u, sidekiq: msg)
        raise
      end
    end

  end

end
