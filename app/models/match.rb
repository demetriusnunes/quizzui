class Match
  include Mongoid::Document
  field :title, type: String
  field :starts_on, type: DateTime
  field :leaderboard, type: Hash

  belongs_to :creator, class_name: "Player"
  has_and_belongs_to_many :players, after_add: :player_added
  has_and_belongs_to_many :eliminated, class_name: "Player"
  has_and_belongs_to_many :alive, class_name: "Player"
  belongs_to :winner, class_name: "Player"

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

    if current_round.question.correct_answer == answer
      self.leaderboard[player] += 2 ** (current_round.level-1) * 10
    else
      self.alive.delete(player)
      self.eliminated << player
    end

    check_round_completion    
  end

  def complete?
    self.winner != nil
  end

  protected
  def player_added(player)
    self.alive << player
    self.leaderboard[player] = 0
  end

  def check_round_completion
    if self.alive.size == 0 ||
       self.alive.all? { |player| self.current_round.answers.include?(player) }
      current_round.complete!
      check_match_completion
    end
  end

  def check_match_completion
    if self.alive.size == 1
      self.winner = self.alive.last
    elsif self.alive.size == 0
      self.winner = leaderboard.sort_by {|k,v|v}.last.first
    end
  end

end
