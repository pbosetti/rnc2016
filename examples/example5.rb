#!/usr/bin/env ruby

# Dealing with files

# More complex example
puts "Creating a File instance:"
file = File.open("test.txt", "r")
# use the file instance
lines = file.readlines
p lines
# remember to close the file
file.close

# Using a block
puts "Using a block:"
File.open("test.txt", "r") do |f|
  p f
  my_lines = f.readlines
  p my_lines
end


# Even better solution
puts "one single operation:"
lns = File.readlines("test.txt")
p lns

# Iterator
# Command line arguments go to the ARGV Array
p ARGV
raise "Need a file name" unless ARGV.size == 1

puts "Using the foreach iterator:"
i = 0
File.open("#{ARGV[0]}.out", "w") do |of|
  File.foreach(ARGV[0]) do |line|
    of.puts "#{i+=1}: #{line}"
  end
end








