require 'test_helper'

class MatchTest < ActiveSupport::TestCase

  test "New match has it own creator as a player" do
    p = Player.new(email: "demetriusnunes@gmail.com")
    m = Match.new(creator: p, 
                  starts_on: 1.minute.from_now,
                  title: "Dema's challenge")

    assert_equal(1, m.players.size)
    assert_equal(p, m.players[0])
  end

  test "Starts a first round with 4 players" do
    m = Match.new(creator: Player.new(email: "demetriusnunes@gmail.com"),
                  starts_on: 1.minute.from_now,
                  title: "Dema's Challenge")

    m.players << Player.new(email: "fhamacher@gmail.com")
    m.players << Player.new(email: "joanahamacher@gmail.com")
    m.players << Player.new(email: "caiohamacher@gmail.com")

    assert_equal(4, m.players.size)
    assert_nil(m.current_round)

    m.start_round!

    assert_not_nil(m.current_round)
    assert_equal(1, m.rounds.size)
    assert_equal(m.current_round, m.rounds[0])

    assert_equal(4, m.alive.size)
    assert_equal(0, m.eliminated.size)

    m.end_round!
  end

  test "A match from start to finish" do
    m = Match.new(creator: p1 = Player.new(email: "demetriusnunes@gmail.com"),
                  starts_on: 1.minute.from_now,
                  title: "Dema's Challenge")

    m.players << p2 = Player.new(email: "fhamacher@gmail.com")
    m.players << p3 = Player.new(email: "joanahamacher@gmail.com")
    
    m.start_round!

    m.try_answer(p1, 2)
    assert_includes(m.alive, p1)
    assert_equal(10, m.leaderboard[p1])
    assert_equal(false, m.current_round.complete?)

    m.try_answer(p2, 2)
    assert_includes(m.alive, p2)
    assert_equal(10, m.leaderboard[p2])
    assert_equal(false, m.current_round.complete?)

    m.try_answer(p3, 3)
    assert_includes(m.eliminated, p3)
    assert_equal(0, m.leaderboard[p3])
    assert_equal(true, m.current_round.complete?)

    m.start_round!

    assert_equal(10, m.leaderboard[p1])
    m.try_answer(p1, 2)
    assert_includes(m.alive, p1)
    assert_equal(30, m.leaderboard[p1])
    assert_equal(false, m.current_round.complete?)

    m.try_answer(p2, 1)
    assert_includes(m.eliminated, p2)
    assert_equal(10, m.leaderboard[p2])
    assert_equal(true, m.current_round.complete?)

    assert_equal(true, m.complete?)
    assert_equal(p1, m.winner)
  end

end
