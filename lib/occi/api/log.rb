require 'logger'

module Occi::Api
  class Log < ::Occi::Log

    SUBSCRIPTION_HANDLE = "rOCCI-api.log"

    attr_reader :core_log

    def initialize(log_dev, log_prefix = '[rOCCI-api]')
      @core_log = ::Occi::Log.new(log_dev)
      super
    end

    def close
      super
      @core_log.close
    end

    # @param severity [::Logger::Severity] severity
    def level=(severity)
      @core_log.level = severity
      super
    end

  end
end
