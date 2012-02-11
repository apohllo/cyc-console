#!/usr/bin/ruby

require 'readline'
require 'colors'
require 'cycr'

module Cyc
  class Configurable

    attr_reader :configuration
    attr_writer :verbose

    def initialize
      load_configuration
    end

    protected
    def say(*args)
      puts *args if @verbose
    end

    def cfg(key)
      @opt["#{key}".intern]
    end

    def load_configuration
      # expand functions file and make sure it exists
      real_path = File.expand_path(cfg('path'))
      unless File.exist?(real_path)
        say "Configuration file #{real_path} doesn't exist."
        @configuration = []
        return
      end

      # read lines from file and add them to configuration list
      @configuration = File.readlines(real_path).map { |line| line.chomp }

      say 'Read %d lines from configuration file %s' % [@configuration.size, cfg('path')]
      @configuration
    end

 end
  #
  # Stolen (with permission from the author :) from Wirble history for IRB
  # http://pablotron.org/software/wirble/
  #
  class History < Configurable
    DEFAULTS = {
      :path   => ENV['CYC_HISTORY_FILE'] || "~/.cyc_history",
      :size   => (ENV['CYC_HISTORY_SIZE'] || 1000).to_i,
      :perms  => File::WRONLY | File::CREAT | File::TRUNC,
    }

    def save_history
      path, max_size, perms = %w{path size perms}.map { |v| cfg(v) }

      # read lines from history, and truncate the list (if necessary)
      lines = Readline::HISTORY.to_a.uniq
      lines = lines[-max_size, -1] if lines.size > max_size

      # write the history file
      real_path = File.expand_path(path)
      File.open(real_path, perms) { |fh| fh.puts lines }
      say 'Saved %d lines to history file %s.' % [lines.size, path]
    end

    public

    def initialize(opt = nil)
      @opt = DEFAULTS.merge(opt || {})
      super()
      return unless defined? Readline::HISTORY
      Readline::HISTORY.push(*self.configuration)
      Kernel.at_exit { save_history }
    end
  end

  class CycFunctions < Configurable
    DEFAULTS = {
      :path   => ENV['CYC_FUNCTIONS_FILE'] || "~/.cyc_functions",
      :perms  => File::WRONLY | File::CREAT | File::TRUNC
    }

    def initialize(opt = nil)
      @opt = DEFAULTS.merge(opt || {})
      super()
    end

    def to_a
      self.configuration
    end
  end

  class Console
    @@constants = []
    @@functions = CycFunctions.new.to_a

    API_QUIT = "(api-quit)"

    # Initializes connection with Cyc runing on host :host: on port :port:
    def initialize(host, port)
      History.new({})
      @host = host
      @port = port
      @cyc = Cyc::Client.new(@host,@port)
      @line = ""
      @count = 0
    end

    def add_autocompletion(str)
      @@constants |= str.split(/[() ]/).select{|e| e =~ /\#\$/}
    end

    # The main loop of the console
    def main_loop
      loop do
        begin
          line = Readline::readline(("cyc@" + "#{@host}:#{@port}" +
              (@count > 0 ? ":#{"("*@count}" : "") + "> "))
          case line
          when nil
            puts
            break
          when API_QUIT,"exit"
            @cyc.raw_talk(API_QUIT) rescue nil
            break
          else
            @line += "\n" unless @line.empty?
            @line += line
            letters = @line.split("")
            Readline::HISTORY.push(@line) if line
            message = @cyc.raw_talk(@line)
            @line = ""
            @count = 0
            puts message.gsub(/(\#\$[\w-]+)/,"\\1".hl(:blue))
            add_autocompletion(message)
          end
        rescue ::Cyc::UnbalancedClosingParenthesis => exception
          puts exception.to_s.sub(/<error>([^<]*)<\/error>/,"\\1".hl(:red))
          @line = ""
        rescue ::Cyc::UnbalancedOpeningParenthesis => exception
          @count = exception.count
        rescue Exception => exception
          puts "Error: " + exception.to_s
          @count = 0
          @line = ""
        end
      end
    end

    CompletionProc = proc {|input|
      case input
      when /\A#/
        @@constants.grep(/^#{Regexp.quote(input)}/)
      when /\A[a-zA-Z-]*\Z/
        @@functions.grep(/#{Regexp.quote(input)}/)
      end
    }
  end
end

