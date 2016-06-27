class Entrant
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'results'

  field :bib, type: Integer
  field :secs, type: Float
  field :o, as: :overall, type: Placing
  field :gender, type: Placing
  field :group, type: Placing

  embeds_many :results, class_name: 'LegResult', order: [:"event.o".asc], after_add: :update_total

  # after_add do |doc|
  # 		self.secs = 0
  # 		update_total(doc)
  # end

  def update_total(result)
  	self.secs = 0
  	results.each do |result|
			self.secs = result.secs + self.secs
		end 
	end

end
