#!/usr/bin/ruby

require 'readline'
require 'colors'
require 'net/telnet'

module Cyc
  class ParenthesisNotMatched < RuntimeError; end

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
      @conn = Net::Telnet.new("Port" => @port, "Telnetmode" => false, 
                              "Host" => @host, "Timeout" => 600)
      @line = ""
      @count = 0
    end

    # Scans the :str: to find out if the parenthesis are matched
    # raises ParenthesisNotMatched exception if there is not matched closing 
    # parenthesis. The message of the exception contains the string with the 
    # unmatched parenthesis highlighted.
    def match_par(str)
      position = 0
      str.scan(/./) do |char| 
        position += 1
        next if char !~ /\(|\)/
        @count += (char == "(" ?  1 : -1)
        if @count < 0 
          @count = 0
          raise ParenthesisNotMatched.
            new((position > 1 ? str[0..position-2] : "") + 
              ")".hl(:red) + str[position..-1])
        end
      end
      @count == 0
    end

    def add_autocompletion(str)
      @@constants |= str.split(/[() ]/).select{|e| e =~ /\#\$/}
    end

    # The main loop of the console
    def main_loop
      loop do
        begin
          line = Readline::readline(("cyc@" + "#{@host}:#{@port}" + 
              (@count > 0 ? ":#{"("*@count}" : "") + "> ").hl(:blue)) 
          case line 
          when API_QUIT 
            @conn.puts(line)
            break
          when "exit"
            @conn.puts(API_QUIT)
            break
          else
            @line += "\n" unless @line.empty?
            @line += line
            letters = @line.split("")
            Readline::HISTORY.push(@line) if line
            if match_par(line)
              @conn.puts(@line)
              @line = ""
              answer = @conn.waitfor(/\d\d\d/)
              message = answer.sub(/(\d\d\d) (.*)\n/,"\\2") if answer
              if($1.to_i == 200)
                puts message
                add_autocompletion(message)
              else
                puts "Error: " + answer.to_s
              end
            end
          end
        rescue ParenthesisNotMatched => exception
          puts exception
          @line = ""
#        rescue Exception => exception
#          puts exception
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

