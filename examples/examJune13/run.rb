#!/usr/bin/env ruby
require './lib/gcode'

fname = "./code.g"

g = Gcode.new(fname)
print "Summary for file #{fname}: "
p g