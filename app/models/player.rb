class Player
  include Mongoid::Document
  field :email, type: String
  
  validates :email, uniqueness: true, presence: true
end
