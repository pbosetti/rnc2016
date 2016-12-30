#!/usr/bin/env ruby

# Main Executable RNC script

require "./lib/rnc.rb"
require "./lib/machine2.rb"
require "./MTViewer/viewer.rb"

# ARGV is the array of command line arguments
# the first command line argument ARGV[0] is assumed to be
# the g-code file name to be run
unless ARGV.size == 1 then
  puts "I need the name of a G-code file as argument!"
  exit
end

# Set this to true for having output on console at each iteration
VERBOSE = false

# Configuration data, collected into a single hash
CONFIG = {
  file: ARGV[0],        # input file
  tq: 0.005,            # quantization time
  tq_corr: (1.596-1.285) / 1.596 / 148.0, # correction factor
  max_pos_error: 0.005, # maximum positioning error for G00
  A:  100,              # maximum acceleration
  D:  100               # maximum deceleration (positive)
}

# Machine tool reference frame
ORIGIN = RNC::Point[0,0,0]


# Instantiate the machine tool dynamics simulator
m = RNC::Machine.new
m.load_configs(["./lib/X.yaml", "./lib/Y.yaml", "./lib/Z.yaml"])
m.go_to ORIGIN  # Set initial contition to machine origin
m.reset         # and at zero velocity and acceleration


# Instantiate the machine tool viewer (GUI)
viewer = Viewer::Link.new("./MTViewer/linux/MTviewer")
viewer.go_to ORIGIN  # Set the viewer position at the origin


# Instantiate a new Parser instance
parser = RNC::Parser.new(CONFIG)
parser.parse_file


# Format string, for 10 values:
format = "%7.3f %7.3f %3d %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f"

# Tell the user to press spacebar (and wait for that)
puts "=" * 79
puts "Press SPACE in the viewer window to start"
puts "=" * 79
loop until (viewer.run)  # viewer.run returns true on spacebar


# We want to save the sequence of states to a file for 
# later visualization
File.open("profiles.txt", "w") do |data_file|
  # Save current clock
  start_time = Time.now

  # Main loop: iterate over g-code lines (aka blocks)
  # remember that the two block arguments are:
  #   interp: an instance of RNC::Interpolator for the current line
  #   n_block: the index (Fixnum) of the current G-code block
  parser.each_block do |interp, n_block|
    puts "N#{n_block}: #{interp.block.inspect}"
    # Check current block type, only deal with G00 and G01
    case interp.block.type
    when :G00
      # Rapid movement: setpoints of axes dtivers are set to 
      # the interp.block.target point and then wait for the axes
      # to reach that coordinate
      m.go_to(interp.block.target.map {|e| e / 1000.0})
      # get the error from the simulator: it is the distance
      # between the setpoint and the actual position:
      error = m.error * 1000 # convert from m  to mm
      
      block_start_time = Time.now - start_time
      while (error >= CONFIG[:max_pos_error]) do 
        # Start parallel thread where we wait for 5 ms
        sleep_thread = Thread.new { sleep CONFIG[:tq] - CONFIG[:tq_corr]}
        
        now = Time.now - start_time
        state = m.step! # forward integration of dynamics equations
        state[:pos].map! {|e| e * 1000} # Convert from m to mm
        error = m.error * 1000
        
        # Build the data array:
        data = [
          now,
          now - block_start_time,
          n_block,
          1 - (error / interp.block.length),
          interp.block.target,
          state[:pos]
        ].flatten # flatten reduces nested arrays to a flat array
        
        # Update viewr position
        viewer.go_to state[:pos]
        
        # Print the formatted output into data_file:
        output_string = format % data
        data_file.puts output_string 
        puts output_string if VERBOSE
        
        # Wait for the timing thread to finish:
        sleep_thread.join
      end
    when :G01
      # Linear interpolation: loop over timesteps until the
      # end of block is reached. Block parameters:
      #   t: current time
      #   cmd: a Hash representing the current positioning command in the
      #        fields :position, :lambda, :type
      interp.each_timestep do |t, cmd|
        # Start parallel thread where we wait for 5 ms
        sleep_thread = Thread.new { sleep CONFIG[:tq] - CONFIG[:tq_corr]}
        
        # Update setpoint to the axes drivers (converted from mm to m)
        m.go_to(cmd[:position].map {|e| e / 1000.0})
        
        # Ask the dynamics simulator to make a step ahead (by 5ms, 
        # internally set)
        state = m.step!
        state[:pos].map! {|e| e * 1000.0 } # convert back from m to mm
        
        # Collect all data into a single array for printout
        data = [
          Time.now - start_time,
          t,
          n_block,
          cmd[:lambda],
          cmd[:position],
          state[:pos]
        ].flatten # flatten reduces nested arrays to a flat array
        
        # Update viewer position (to the real position calculated by
        # the dynamics simulator, not to the nominal one!):
        viewer.go_to state[:pos]
        
        # data string to be printed and saved into the data_file:
        output_string = format % data
        data_file.puts output_string
        puts output_string if VERBOSE
        
        # Wait fro the sleep_thread to end waiting
        sleep_thread.join
      end
    else # Unsupported command
      puts "Skipping unsupported block #{interp.block.type}"
    end
    
  end # iteration over G-code blocks
end # close the data_file


puts "=" * 79
puts "Press SPACE in the viewer window to stop"
puts "=" * 79
loop while (viewer.run)

viewer.close

puts "Now run the command 'gnuplot -p plot.gp' for a chart..."

