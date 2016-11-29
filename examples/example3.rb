#!/usr/bin/env ruby

# Inheritance

class Polygon
  attr_accessor :color
  attr_reader :sides
  
  def initialize(sides, color)
    @sides = sides
    @color = color
  end
  
  def inspect
    return "A #{@color} polygon with #{@sides} sides"
  end
  
  def to_s
    return "A Polygon"
  end
end



class Triangle < Polygon
  def initialize(color)
    super(3, color)
  end
  
  def inspect
    return super + "\nIn this case a Triangle"
  end

end # class Triangle



class Square < Polygon
  def initialize(color)
    super(4, color)
  end

end # class Square
