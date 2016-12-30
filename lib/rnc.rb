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
    
    def initialize(l="G00 X0 Y0 Z0 F1000 S1000")
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
  
  
  
  class Parser
  # Class for loading a G-Code File and iteratively
  # create a new Block instance for each line
    attr_reader :blocks
  
    def initialize(cfg)
      raise "Need a Hash configuration" unless cfg.kind_of? Hash
      raise "Missing filename" unless cfg[:file]
      @cfg = cfg
      @blocks = [Block.new()]
      @profiler = Profiler.new(@cfg)
      @interp   = Interpolator.new(@cfg)
    end
  
  
    def parse_file
      File.foreach(@cfg[:file]) do |line|
        next if line.length <= 1
        next if line[0] == '#'
        b = Block.new(line)
        b.modal!(@blocks.last)
        b.profile = @profiler.velocity_profile(b.feed_rate, b.length)
        # later on, we will do: b.profile.call(t) => {:lambda=>0.2, :type=>:A}
        b.dt = @profiler.dt 
        @blocks << b
      end
    end
    
    def each_block
      raise "I need a block!" unless block_given?
      @blocks.each_with_index do |b, i|
        @interp.block = b
        yield @interp, i
      end
    end
  
    def inspect
      result = ""
      @blocks.each_with_index do |b, i|
        result << "#{i}: #{b.inspect}\n"
      end
      return result
    end
  
  end # class Parser
  
  
  class Profiler
    attr_reader :dt, :accel, :feed_rate, :times
    def initialize(cfg)
      raise "Need a Hash" unless cfg.kind_of? Hash
      [:A, :D, :tq].each do |k|
        raise "cfg[#{k}] is missing" unless cfg[k]
      end
      @cfg = cfg
    end
    
    # returns the lambda function as a Proc instance
    def velocity_profile(f_m, l)
      # Convert from mm/min to mm/s
      f_m /= 60.0 
      l = l.to_f
      # Nominal time intervals before quantization:
      dt_1 = f_m / @cfg[:A] # cfg[:A] > 0
      dt_2 = f_m / @cfg[:D] # cfg[:D] > 0
      dt_m = l / f_m - (dt_1 + dt_2) / 2.0
      
      if dt_m > 0 then # Trapezoidal profile
        q = quantize(dt_1 + dt_m + dt_2, @cfg[:tq])
        dt_m += q[1] # this is dt_m*
        f_m = (2 * l ) / (dt_1 + dt_2 + 2 * dt_m)
      else # Triangular profile
        dt_1 = Math::sqrt(2 * l / (@cfg[:A] + @cfg[:A] ** 2 / @cfg[:D]))
        dt_2 = dt_1 * @cfg[:A] / @cfg[:D]
        q = quantize(dt_1 + dt_2, @cfg[:tq])
        dt_m = 0.0
        f_m = 2 * l / (dt_1 + dt_2)
      end
      a = f_m / dt_1
      d = -(f_m / dt_2)
      
      @times = [dt_1, dt_m, dt_2]
      @accel = [a, d]
      @feed_rate = f_m
      @dt = q[0]
      
      return proc do |t|
        r = 0.0
        if t < dt_1 then # during acceleration
          type = :A
          r = a * (t ** 2) / 2.0
        elsif t < (dt_1 + dt_m) then # during maintenance
          type = :M
          r = f_m * (dt_1 / 2.0 + (t - dt_1))
        else # during deceleration 
          type = :D
          t_2 = dt_1 + dt_m
          r = f_m * dt_1 / 2.0 + f_m * (dt_m + t - t_2) + d / 2.0 * (t ** 2 + t_2 ** 2) - d * t * t_2
        end
        {:lambda => r / l, :type => type}
      end
      
    end
    
    private
    def quantize(t, dt)
      if (t % dt) == 0 then
        result = [t, 0.0]
      else
        result = []
        result[0] = ((t / dt).to_i + 1) * dt
        result[1] = result[0] - t
      end
      return result
    end
    
  end # class Profiler
  
  
  class Interpolator
    attr_accessor :block
    def initialize(cfg)
      @cfg = cfg
      @block = nil
    end
    
    def eval(t)
      raise "undefined block" unless @block.kind_of? Block
      result = {}
      case @block.type
      when :G00 # rapid positioning
        result[:position] = @block.target
        result[:lambda]   = 0.0
        result[:type]     = :R
      when :G01 # linear interpolation
        if (0..@block.dt).include? t then
          result = @block.profile.call(t)
          result[:position] = Point[]
          [:X, :Y, :Z].each do |axis|
            result[:position][axis] = @block.start[axis] + result[:lambda] * @block.delta[axis]
          end
        else
          return nil
        end
      else # unsupported G command
        raise "Unsupported G-code command #{@block.type}!"
      end
      
      return result # Hash with keys: :lambda, :type, :position
    end
    
    def each_timestep
      raise "I need a block" unless block_given?
      t = 0.0
      while (cmd = self.eval(t)) do
        yield t, cmd
        t += @cfg[:tq]
      end
    end
    
  end # class Interpolator
  
  

end # module RNC








