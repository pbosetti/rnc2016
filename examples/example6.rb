#!/usr/bin/env ruby

# Blocks

def repeat(times)
  for k in 1..times do
    if block_given? then
      yield k
    else
      puts k
    end
  end
end

def transform(string, &block)
  # block is an instance of the Proc class
  return block.call(string).to_s
end


repeat(5) {|i| puts "this is iteration number #{i}" }


puts transform("Example string") {|s| s.upcase }

puts transform("Example string") {|s| "#{s} (#{s.length} chars)"}



