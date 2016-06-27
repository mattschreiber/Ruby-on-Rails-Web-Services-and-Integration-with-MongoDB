class RunResult < LegResult
  include Mongoid::Document
  field :mmile, as: :minute_mile, type: Float

  def calc_ave
  	self[:minute_mile] = self.event.nil? ? nil : (self[:secs]/60)/self.event.miles
  end
end
