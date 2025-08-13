module Debugr
  class REPL
    def initialize(engine, trace)
      @engine = engine
      @trace = trace
    end

    def start
      loop do
        print "(debugr) > "
        input = gets.chomp

        case input
        when 'n', 'next'
          @engine.next!
        when 's', 'step'
          @engine.step!
        when 'c', 'continue'
          @engine.continue!
        when 'q', 'quit', 'exit'
          puts "Exiting debugger..."
          break
        when 'help', 'h', '?'
          puts "Commands:"
          puts "  n/next - next"
          puts "  s/step - step"
          puts "  c/continue - continue"
          puts "  q/quit/exit - quit"
          puts "  h/help/? - help"
        else
          puts "Unknwon command: #{input}"
        end
      end
    end
  end
end