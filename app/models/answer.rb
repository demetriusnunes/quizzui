class Answer
  include Mongoid::Document
  field :choice, type: Integer

  belongs_to :player
  belongs_to :question
end
