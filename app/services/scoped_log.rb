class ScopedLog
  class EmptyMessageError < StandardError; end
  class InvalidMessageError < StandardError; end

  class Logger
    def initialize(scopes = [])
      @scopes = scopes
      @log_prefix = @scopes.map { |s| "[#{s}]" }.join
    end

    def scope(new_scope)
      Logger.new(@scopes + [ new_scope ])
    end

    def info(msg)
      message = build_message(msg)
      Rails.logger.info(message)
    rescue EmptyMessageError, InvalidMessageError
      nil
    end

    def warn(msg)
      message = build_message(msg)
      Rails.logger.warn(message)
    rescue EmptyMessageError, InvalidMessageError
      nil
    end

    def error(msg)
      message = build_message(msg)
      Rails.logger.error(message)
    rescue EmptyMessageError, InvalidMessageError
      nil
    end

    def debug(msg)
      message = build_message(msg)
      Rails.logger.debug(message)
    rescue EmptyMessageError, InvalidMessageError
      nil
    end

    private

    def build_message(msg)
      raise EmptyMessageError if msg.nil?
      raise InvalidMessageError unless msg.is_a?(String)

      "#{@log_prefix} #{msg}"
    end
  end
end
