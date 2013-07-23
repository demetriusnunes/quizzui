class Round
  include Mongoid::Document
  field :level, type: Integer
  field :started_on, type: Time
  field :completed_on, type: Time
  field :answers, type: Hash

  embeds_one :question

  validates :level, presence: true

  after_initialize do |round|
    round.answers = {}
    round.started_on = Time.now
    round.question = pick_question(round.level)
  end

  def complete!
    self.completed_on = Time.now
    save
  end

  def complete?
    self.completed_on != nil
  end

  def pick_question(level)
    Question.new( title: "What is Brazil's capitol?",
                  difficulty: level, 
                  factoid: "Rio de Janeiro was the capitol until 1963",
                  hint: "Brazilians don't speak spanish",
                  answers: [ "Rio de Janeiro", "São Paulo", "Brasília", "Buenos Aires"],
                  correct_answer: 2 )
  end

end
