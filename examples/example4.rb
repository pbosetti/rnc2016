#!/usr/bin/env ruby

#  Containers


# Array
ary1 = [3, 8, 1, 23, 5.7, 0.1, 0]

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
