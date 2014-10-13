module DucksboardReporter
  class Widget
    include Celluloid
    include Celluloid::Logger

    attr_reader :id, :reporter, :options, :updater

    def initialize(klass, id, reporter, options = {})
      @klass = klass
      @id = id
      @reporter = reporter
      @options = options
      @updater = instanciate_updater
    end

    def start
      debug log_format("Started using reporter #{reporter.name}")

      every(interval) do
        update
      end
    end

    def update
      value = map_value(value_method)
      debug log_format("Updating value #{value}")

      @updater.update(value)
    rescue Net::ReadTimeout, Net::OpenTimeout
      # accept timeout errors
    end

    def interval
      options[:interval] || 10
    end

    private

    def log_format(msg)
      @log_prefix ||= "Widget #{@klass}(#{id}): "
      @log_prefix + msg
    end

    def value_method
      options[:value] || :value
    end

    def instanciate_updater
      klass = Class.new(Ducksboard::Widget)
      klass.default_timeout(interval - 1)
      klass.new(@id)
    end

    def map_value(object)
      p object
      case object
      when Symbol, /\A:/
        @reporter.public_send(object)
      when Hash
        object.inject({}) do |memo, (k, v)|
          memo[k] = map_value(v)
          memo
        end
      else
        object
      end
    end
  end
end

