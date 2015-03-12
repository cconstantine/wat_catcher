module WatCatcher
  class SidekiqMiddleware
    def call(worker, msg, queue)
      begin
        yield
      rescue => excpt
        raise if thrown_by_watcatcher?(msg)
        u = nil
        begin
          if worker.class == Sidekiq::Extensions::DelayedClass
            (worker,method_name,args) = YAML.load(msg["args"][0])
          end
          if worker.respond_to? :wat_user
            u = worker.wat_user(*msg["args"])
          else
            u = { id: "jid_#{msg["jid"]}", jid: msg["jid"] }
          end

        rescue; raise
        end

        WatCatcher::Report.new(excpt, user: u, sidekiq: msg)
        raise
      end
    end

    def thrown_by_watcatcher?(msg)
      msg["class"] =~ /WatCatcher/
    end
  end

end
