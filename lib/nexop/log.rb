require 'log4r'

module Nexop
  ##
  # Logging utility.
  #
  # Including the module into a class will provide a {#log}-method, which
  # returns a `Log4r::Logger`-instance. The `fullname` of the logger will be
  # set to the class-name, so you have all the ancestors-support of `Log4r`.
  #
  # The initial configuration is taken from the {config}-hash.
  module Log
    ##
    # Returns a logger for the current `Class`.
    #
    # @return [Log4r::Logger] a logger for the current class
    def log
      fullname = self.class.name

      unless logger = Log4r::Logger[fullname]
        logger = Log4r::Logger.new(fullname)
        logger.level = Nexop::Log::config[:level]
        logger.outputters = Nexop::Log::config[:outputters]
      end

      logger
    end

    ##
    # Returns the configuration-hash for all loggers.
    #
    # There are two keys:
    #
    # 1. `:level`: Defines the level for all loggers
    # 2. `:outputters`: Defines the outputters for all loggers
    #
    # @return [Hash] Initial configuration for all new logger
    def self.config
      Log4r::Logger.root

      @log_config ||= {
        :level => ::Log4r::DEBUG,
        :outputters => ::Log4r::Outputter.stdout
      }
    end
  end
end
