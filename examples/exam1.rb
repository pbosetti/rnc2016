#!/usr/bin/env ruby

require "./lib/lathe.rb"

cfg = {
  unit_energy: 1.1, # W s / mm^3
  speed: 600,       # mm/min
  feed: 0.6         # mm/rev
}

# Instantiate Lathe and define parameters
lathe  = Lathe.new(cfg)
diam   = 150 # Workpiece diameter
d0     = 2   # Initial depth of cut
df     = 5   # Final depth of cut
length = 250 # Workpiece length
step   = 10  # Step length, in mm
n      = (length / step).to_i # Total number of steps

# Print table header, same column widths used later on
header = %w(i x d mrr fr N T P)
puts "%3s %9s %9s %9s %9s %9s %9s %9s" % header

# Loop on z position
0.upto(n) do |i|
  z = step * i # Current z position
  doc = d0 + (z * (df - d0)/length.to_f) # current depth of cut
  d = diam - 2 * doc # current cutting diameter
  
  # Prepare data array, one per line
  ary = [i, z, d]
  ary += lathe.status(d, doc)
  
  # Four significant digits: we must use scientific notation
  # '%.3e' means 'use scientific notation with 3 decimals'
  puts "%3d %.3e %.3e %.3e %.3e %.3e %.3e %.3e" % ary
end
