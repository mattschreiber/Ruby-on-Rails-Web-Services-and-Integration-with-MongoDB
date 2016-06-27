class SwimResult <  LegResult
  include Mongoid::Document
  field :pace_100, type: Float

  def calc_ave
  	self[:pace_100] = self.event.nil? ? nil : self[:secs]/(self.event.meters/100)
  end
end
