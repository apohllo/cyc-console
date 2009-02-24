require 'readline'
require 'cycr'
require 'nlp'

module Cyc
  class Console
    @@constants = []

    API_QUIT = "(api-quit)"
    def initialize(host="localhost", port=3601)
      @port = port
      @host = host
      @conn = Net::Telnet.new("Port" => @port, "Telnetmode" => false, 
                              "Host" => @host, "Timeout" => 600)
      @line = ""
      @sub_prompt = 0
    end

    def main_loop
      loop do
        line = Readline::readline(("cyc@" + "#{@host}:#{@port}" + 
            (@sub_prompt > 0 ? ":#@sub_prompt" : "") + "> ").hl(:blue)) 
        case line 
        when API_QUIT 
          @conn.puts(line)
          break
        when "exit"
          @conn.puts(API_QUIT)
          break
        else
          @line += " " unless @line.empty?
          @line += line
          letters = @line.split("")
          if(letters.inject(0){|sum,l| l == "(" ? sum += 1 : sum} == 
             letters.inject(0){|sum,l| l == ")" ? sum += 1 : sum})
            Readline::HISTORY.push(@line) if line
            @conn.puts(@line)
            @line = ""
            answer = @conn.waitfor(/\d\d\d/)
            message = answer.sub(/(\d\d\d) (.*)\n/,"\\2") if answer
            if($1.to_i == 200)
              #@@constants |= message.split(/[() ]/).select{|e| e =~ /\#\$/}
              puts message
            else
              puts "Error: " + answer.to_s
            end
            @sub_prompt = 0
          else
            @sub_prompt += 1
          end
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

console = Cyc::Console.new(ARGV[0],ARGV[1])
console.main_loop
