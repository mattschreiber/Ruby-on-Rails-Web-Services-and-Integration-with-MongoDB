class Actor
  include Mongoid::Document
  include Mongoid::Timestamps
  field :first_name, type: String
  field :last_name, type: String

  #backwards-compatible reader
  def name
    "#{first_name} #{last_name}"
  end
  #backwards-compatible writer
  def name= value
    if !value
        first_name=nil
        last_name=nil
    else
      names= value.split(' ')
      self.first_name=names[0]
      self.last_name=names[1]  if names.count>0
    end
  end

  def roles
    Movie.where(:"roles.actor_id"=>self.id).map {|m|m.roles.where(:actor_id=>self.id).first}
  end
end
