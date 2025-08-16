# frozen_string_literal: true

# Basic method
def add(x, y)
  x + y # Line #5: test locals and eval z here
end

# A method that calls another method.
def calculate
  a = 10        # Line 10
  b = add(a, 5) # Line 11
  b * 2 # Line 12
end

puts 'Starting script...' # Line 15

# A loop to test breakpoints and continue.
(1..3).each do |i|
  puts "Loop iteration: #{i}" # Line 19: Set a breakpoint here with 'b 19'.
end

final_result = calculate # Line 22

puts "Script finished. Result: #{final_result}" # Line 24
