module WatCatcher
  class Metrics
    attr_writer :host, :port

    def host
      @host ||= 'localhost'
    end

    def port
      @port ||= 9125
    end

    def client
      ::Statsd.new @host, @port
    end

    def increment(metric, sample_rate=1)
      client.increment metric, sample_rate
    end

    def decrement(metric, sample_rate=1)
      client.increment metric, sample_rate
    end

    def set(metric, value, sample_rate=1)
      client.set metric, value, sample_rate
    end
  end
end
