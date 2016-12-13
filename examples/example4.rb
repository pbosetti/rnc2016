#!/usr/bin/env ruby

#  Containers


# Array
# Ordered list of objects (heterogeneous)

ary1 = [3, 8, 1, 23, 5.7, 0.1, 0]
ary1[0] # returns the very first element of ary1

ary2 = []
# also ary2 = Array.new
ary2 << "Paolo"
ary2 << "Bosetti"

ary1.each {|e| puts e}

ary1.each_with_index do |e,i|
  puts "ary1[#{i}] = #{e}"
end

ary3 = ary1.map {|e| e / 2.0 }
p ary3

ary1.map! {|e| e * 2}
p ary1

# Hash
# A Hash is a list of "key-value" pairs (heterogeneous)
hsh = {"name" => "Paolo", "surname" => "Bosetti", "age" => 15}
hsh["name"] # => "Paolo"
hsh["age"] = 25
hsh["address"] = "Via Sommarive 9, Trento"
p hsh

hsh = {:one => 1, :two => 2, :three => 3}
# compact syntax when creating Hashes:
hsh = {one: 1, two: 2, three: 3, another_key: "test"}
p hsh

p hsh.keys   # => Array of keys
p hsh.values # => Array of values

# Looping and iterating on Hash elements:
puts "Iterating on a Hash:"
hsh.each do |k, v|
  puts "hsh[#{k}] is #{v}"
end









