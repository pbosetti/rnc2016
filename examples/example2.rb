#!/usr/bin/env ruby

# Object Oriented Programming

class Chalk # Class name MUST staty with a caital letter
  attr_accessor :color
  attr_reader :length
  attr_writer
  
  def initialize(c, l=10.0)
    self.length = l
    @color = c
  end
  
  # "getter" accessor
  # def length
  #   return @length
  # end
  
  # "setter" accessor
  def length=(new_value) # NO SPACES!
    raise "I need a Numeric" unless new_value.kind_of? Numeric
    @length = new_value
  end
  
  def write(words)
    if @length > 2 then
      puts "#{words} (in #{@color})"
      @length -= (0.5 * words.length)
    else
      puts "This chalk is too short!"
    end
  end
  
end


c1 = Chalk.new("white")
c2 = Chalk.new("brown", "12")

c1.write "Hello"
c2.write "Hello"

puts "length of c1 is #{ c1.length }"
puts "length of c2 is #{ c2.length }"

c1.length = 6  # SPACES ALLOWED! (and no parentheses too)









