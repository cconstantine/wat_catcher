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
          elsif worker.method(:perform).parameters.length == 1 && worker.method(:perform).parameters[0].length > 1
            params = worker.method(:perform).parameters[0]
            args = []
            params.slice(1, params.count).each_with_index do |parm, i|
              args << "#{parm}_#{msg['args'][i]}"
            end
            u = { id: args.join("__"), jid: msg["jid"] }
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
