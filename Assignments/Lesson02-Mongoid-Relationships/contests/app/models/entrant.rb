class Entrant
  include Mongoid::Document
  field :_id, type: Integer
  field :name, type: String
  field :group, type: String
  field :secs, type: Float

  belongs_to :racer
  embedded_in :contest

  validates_associated :racer

  before_create do |racer|
  	racer.name = "#{Racer.find(racer_id).last_name}, #{Racer.find(racer_id).first_name}"
  end
end
