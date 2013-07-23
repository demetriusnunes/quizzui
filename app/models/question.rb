class Question
  include Mongoid::Document
  field :title, type: String
  field :difficulty, type: Integer
  field :factoid, type: String
  field :hint, type: String
  field :answers, type: Array
  field :correct_answer, type: Integer
  belongs_to :category
  
end
