#!/usr/bin/env ruby

# This is the first exercise

# Printing a string
print("Hello, World!\n")

# puts() is like print() plus a newline \n
puts "Hello, World (again)!", "second arg"

# Variables
a = 10
b = 12
c = a * b
# String interpolation (only with double quotes):
puts "a * b = #{a * b}\n"

# Single-quoted strings are not interpolated
puts 'a * b = #{c}\n'

# Floats:
puts 10 / 3
puts 10.0 / 3

# Arrays
ary1 = [1, 2, 3]
ary2 = [1, "one", [1, 2, 3]]
puts ary1
# p() prints a description of an object
p ary1
p ary2

# Slicing (= accessing array elements)
puts "First element of ary1 is #{ary1[0]}"
puts "Last element of ary2 is #{ary2[-1]}"

# Errors and nil values
# puts ary[1] #this raises an error
puts ary1[3]

# Conditionals
if 1 == a then    # the "then" is optional
  puts "One!"
  if b > 0 then
    puts "also, b is positive"
  end
  # empty line
elsif 2 == a then # zero or more times
  puts "Two!"
else              # zero or one times
  puts "LARGE!"
end

# postfix checks
if a > 0 then
  puts a
end

puts a if a > 0

puts "a is #{a > 0 ? "positive" : "negative"}"

# Functions
def myfun(str, n = 1)
  result = str * n
  return result
end

puts myfun(10)

# More compact
def myfun2(str, n=1)
  str * n
end







