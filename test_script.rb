def inner
  puts "hi from inner"
end

def outer
  a = 1           # Line 6
  inner           # Line 7
  b = 2           # Line 8
end

target_depth = nil

trace = TracePoint.new(:call, :return, :line) do |tp|
  current_depth = caller.size

  case tp.event
  when :line
    puts "[line] #{tp.path}:#{tp.lineno}, depth=#{current_depth}"

    if target_depth && current_depth == target_depth
      puts ">>> pausing here at #{tp.lineno}"
      target_depth = nil
      binding.irb # simulate pause
    end

  when :call
    puts "[call] #{tp.defined_class}##{tp.method_id}, depth=#{current_depth}"

  when :return
    puts "[return] #{tp.defined_class}##{tp.method_id}, depth=#{current_depth}"
  end
end

trace.enable

# Simulate: paused at line 8 in outer, now run `next`
target_depth = caller.size + 0 # same depth we’re at now
outer
