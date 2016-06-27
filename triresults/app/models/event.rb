class Event
  include Mongoid::Document
  field :o, as: :order, type: Integer
  field :n, as: :name, type: String
  field :d, as: :distance, type: Float
  field :u, as: :units, type: String

  embedded_in :parent, polymorphic: true, touch: true
  validates_presence_of :order, :name

  def meters
  	case
  	when self[:u] == "miles"
  		self[:d] * 1609.344
  	when self[:u] == "kilometers"
  		self[:d] * 1000
  	when self[:u] == "yards"
  		self[:d] * 0.9144
  	when self[:u] == "meters"
  		self[:d]
  	else
  		nil
  	end
	end

  def miles
  	case
  	when self[:u] == "meters"
  		self[:d]  * 0.000621371
  	when self[:u] == "kilometers"
  		self[:d] * 0.621371
  	when self[:u] == "yards"
  		self[:d]* 0.000568182
  	when self[:u] == "miles"
  		self[:d]
  	else
  		nil
  	end
  end
end
