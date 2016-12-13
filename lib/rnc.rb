#!/usr/bin/env ruby

# Ruby Numerical Control (RNC) Library

module RNC    # Name of modules follow the class convention
  AXES = {:X => 0, :Y => 1, :Z => 2}
  COMMANDS = [:G00, :G01]
  
  class Point < Array
  # Represents a coordinate in 3-D space, including common ops
    def Point.[](x=nil, y=nil, z=nil)
      point = Point.new
      point[:X] = x
      point[:Y] = y
      point[:Z] = z
      return point
    end
  
    def -(other)
      raise "Operand must be a RNC::Point" unless other.kind_of? Point
      return Math::sqrt(
        (self[0] - other[0]) ** 2 +
        (self[1] - other[1]) ** 2 +
        (self[2] - other[2]) ** 2
      )
    end
    
    def delta(other)
      result = Point[]
      AXES.keys.each do |axis|
        result[axis] = self[axis] - other[axis]
      end
      return result
    end
    
    def modal!(other)
      AXES.keys.each do |axis|
        self[axis] = other[axis] unless self[axis]
      end
    end
    
    def [](idx)
      # self[remap_index(idx)] # NOT WORKING! is an infinite loop!
      super(remap_index(idx))
    end
    
    def []=(idx, value)
      # self[remap_index(idx)] = value
      super(remap_index(idx), value)
    end
    
    def inspect
      return "[#{self[:X].round(3)} #{self[:Y].round(3)} #{self[:Z].round(3)}]"
    end
    
    private
    def remap_index(idx)
      case idx
      when Numeric
        return idx.to_i
      when Symbol
        return AXES[idx]
      when String
        return AXES[idx.upcase.to_sym]
      else
        raise "Point index must be a number or string or symbol"
      end
    end

  end # class Point
  
  
  
  
  # Block class, representing a LINE OF G-CODE
  class Block
    attr_reader :line
    attr_reader :start, :target, :feed_rate, :spindle_rate
    attr_reader :length, :type, :delta
    attr_accessor :profile, :dt
    
    def initialize(l="G00 X0 Y0 Z0 F1000")
      @start = Point[]
      @target = Point[]
      @feed_rate = nil
      @spindle_rate = nil
      @delta = Point[]
      @type = nil
      @length = nil
      @profile = nil
      @dt = nil
      self.line = l
    end
    
    def line=(str)
      @line = str.upcase
      self.parse
    end
    
    def parse
      tokens = @line.split # array of words
      @type = tokens.shift.to_sym
      unless COMMANDS.include? @type then
        raise "Unsupported command #{@type}"
      end
      tokens.each do |token|
        # token is a string where token[0] is the command
        # and token[1..-1] is the argument
        cmd = token[0]
        arg = token[1..-1].to_f
        case cmd
        when "F"
          @feed_rate = arg
        when "S"
          @spindle_rate = arg
        when "X", "Y", "Z"
          @target[cmd] = arg
        else
          raise "Unsupported G-Code command #{cmd}"
        end
      end
    end
    
    def modal!(prev_block)
      raise "Need a Block!" unless prev_block.kind_of? Block
      @start = prev_block.target
      @target.modal!(@start)
      @feed_rate ||= prev_block.feed_rate
      @spindle_rate ||= prev_block.spindle_rate
      @length = @target - @start
      @delta = @target.delta(@start)
      return self
    end
    
    def inspect
      "[#{@type} #{@target} L#{@length} F#{@feed_rate} S#{@spindle_rate}]"
    end
  
  end # class Block
  
  

end # module RNC


g0 = RNC::Block.new
g1 = RNC::Block.new("G01 X200 Y300 F500")

p g0
p g1


