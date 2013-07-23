class Match
  include Mongoid::Document
  field :title, type: String
  field :starts_on, type: DateTime
  field :leaderboard, type: Hash

  belongs_to :creator, class_name: "Player"
  has_and_belongs_to_many :players, after_add: :player_added
  has_and_belongs_to_many :eliminated, class_name: "Player"
  has_and_belongs_to_many :alive, class_name: "Player"

  embeds_many :rounds

  validates :title, :starts_on, :creator, presence: true

  after_initialize do |match|
    match.leaderboard = {}
    match.players << match.creator
  end


  def start_round!
    rounds << Round.new(level: rounds.size + 1)
  end

  def end_round!
    current_round.complete!
  end

  def current_round
    rounds.last
  end

  def try_answer(player, answer)
    current_round.answers[player] = answer

    check_round_completion    

    if current_round.question.correct_answer == answer
      self.leaderboard[player] += (2 ** current_round.level-1) * 10
      return true
    else
      self.alive.delete(player)
      self.eliminated << player
      return false
    end
  end

  protected
  def player_added(player)
    self.alive << player
    self.leaderboard[player] = 0
  end

  def check_round_completion
    if self.alive.all? { |player| self.current_round.answers.include?(player) }
      current_round.complete!
    end
  end
end
