class BikeResult < LegResult
  include Mongoid::Document
  field :mph, type: Float

  def calc_ave
  	self[:mph] = self.event.nil? ? nil : self.event.miles*3600/self[:secs]
  end
end
