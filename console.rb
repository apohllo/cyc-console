require 'readline'
require 'nlp'
require 'net/telnet'

module Cyc
  class ParenthesisNotMatched < RuntimeError; end
  #
  # Stolen from Wirble history for IRB 
  # http://pablotron.org/software/wirble/
  #
  class History
    DEFAULTS = {
      :history_path   => ENV['CYC_HISTORY_FILE'] || "~/.cyc_history",
      :history_size   => (ENV['CYC_HISTORY_SIZE'] || 1000).to_i,
      :history_perms  => File::WRONLY | File::CREAT | File::TRUNC,
    }
 
    private

    def say(*args)
      puts *args if @verbose
    end

    def cfg(key)
      @opt["history_#{key}".intern]
    end

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

    def load_history
      # expand history file and make sure it exists
      real_path = File.expand_path(cfg('path'))
      unless File.exist?(real_path)
        say "History file #{real_path} doesn't exist."
        return
      end

      # read lines from file and add them to history
      lines = File.readlines(real_path).map { |line| line.chomp }
      Readline::HISTORY.push(*lines)

      say 'Read %d lines from history file %s' % [lines.size, cfg('path')]
    end

    public

    def initialize(opt = nil)
      @opt = DEFAULTS.merge(opt || {})
      return unless defined? Readline::HISTORY
      load_history
      Kernel.at_exit { save_history }
    end
  end

  class Console
    @@constants = []

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
      candidates = %w{denotation-mapper}
      @@constants.grep(/^#{Regexp.quote(input)}/)
    }
  end
end

if Readline.respond_to?("basic_word_break_characters=")
  Readline.basic_word_break_characters= " \t\n\"\\'`><=;|&{("
end
Readline.completion_append_character = nil
Readline.completion_proc = Cyc::Console::CompletionProc

host = ARGV[0] || "localhost"
port = ARGV[1] || 3601
console = Cyc::Console.new(host,port)
console.main_loop
