#!/usr/bin/env ruby
class Move
  attr_accessor :feed_rate, :start, :target
  def initialize
    @start, @target = nil
  end
  
  def length
    return 0.0 # default for base class, never used
  end
  
  def time; return self.length / @feed_rate; end
end #class Move

class LineMove < Move
  def length
    return Math::sqrt( (@target[:x] - @start[:x])**2 + 
                      (@target[:z] - @start[:z])**2 )
  end
end #class LineMove

class ArcMove < Move
  def length
    center = [@start[:x] + @target[:i], @start[:z] + @target[:k]]
    p1 = [-@target[:i], -@target[:k]] # in center-coordinates
    p2 = [@target[:x] - center[0], @target[:z] - center[1]] # in center-ccordinates
    radius = Math::sqrt( p1[0]**2 + p1[1]**2 )
    arc1 = Math::atan2(p1[0], p1[1]) # >0 if in I and II quadrant
    arc2 = Math::atan2(p2[0], p2[1]) # <0 if in III and IV quadrant
    sgn = -(arc1 * arc2) / (arc1 * arc2).abs
    arc = arc2 + sgn * arc1
    return (radius * arc).abs
  end
end #class ArcMove


class Gcode
  RAPID = 20_000 #default rapid feed rate
  attr_accessor :moves, :count
  
  def initialize(fname = nil)
    @previous = {x:0, z:0, i:0, k:0}
    @moves = [] # will hold array of LineMove or ArcMove
    self.load(fname) if fname
  end
  
  def load(fname)
    @count = 0
    @fname = fname
    target = @previous.dup
    incremental = false
    feed_rate = 0.0
    @moves = []
    
    File.foreach(@fname) do |l| # Loops on all lines
      commands = l.split
      m = nil
      commands.each do |c| # Loops on all "words" in current line
        case c[0]
        when 'X'
          target[:x] = c[1..-1].to_f / 2.0
        when 'Z'
          target[:z] = c[1..-1].to_f
        when 'I'
          target[:i] = c[1..-1].to_f
        when 'K'
          target[:k] = c[1..-1].to_f
        when 'F'
          feed_rate = c[1..-1].to_f
        end
        
        case c
        when 'G00'
          m = LineMove.new
          m.feed_rate = RAPID
        when 'G01'
          m = LineMove.new
        when 'G02', 'G03'
          m = ArcMove.new
        when 'G91'
          incremental = true
        when 'G90'
          incremental = false
        end
        
      end #each
      
      if incremental then
        [:x, :z].each {|axis| target[axis] += @previous[axis]}
      end
      
      if m then # Skips blocks not containing motion (where m is nil)
        m.feed_rate = feed_rate unless m.feed_rate #unless already defined (rapid)
        m.start = @previous
        m.target = target.dup
        moves << m
        @previous = target.dup
        @count += 1
      end
      
    end #foreach
  end #load
  
  def length
    return @moves.inject(0) {|sum, m| sum + m.length} # sum of lengths
  end
  
  def time
    return @moves.inject(0) {|sum, m| sum + m.time} # sum of times
  end
  
  def inspect
    return "%d motion blocks, %.3f mm, %.2f min" % [@count, self.length, self.time]
  end
end #class Gcode