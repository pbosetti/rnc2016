#!/usr/bin/env ruby

class Lathe
  attr_accessor :unit_energy, # W s/mm^3 
                :feed,        # feed per revolution, mm/rev
                :speed        # cutting speed, mm^s
  
  def initialize(cfg)
    @unit_energy = cfg[:unit_energy] || 0.0 # cfg field or a default value
    @speed       = cfg[:speed]       || 0.0 # cfg field or a default value
    @feed        = cfg[:feed]        || 0.0 # cfg field or a default value
  end
  
  def rotary_speed(diam)
    return (@speed / (Math::PI * diam)) # rpm
  end
  
  def feed_rate(diam)
    return self.rotary_speed(diam) * @feed
  end
  
  def mrr(doc) # doc is depth of cut
    return doc * @feed * @speed
  end
  
  def torque(diam, doc) # T = P/omega
    return self.power(doc) / (self.rotary_speed(diam) / 30.0 * Math::PI)
  end
  
  def power(doc)
    return (self.mrr(doc) / 60.0) * @unit_energy
  end
  
  def status(diam, doc)
    return [self.mrr(doc), self.feed_rate(diam), self.rotary_speed(diam), self.torque(diam, doc), self.power(doc)]
  end
  
end