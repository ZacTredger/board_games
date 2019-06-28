# Create series of games where they take turns
class TurnBasedSeries < Series
  def take_turn(which)
    midgame_data = @game.move(@names[which], which)
    return save_game(midgame_data) if midgame_data.is_a? Hash

    game_over?(which, midgame_data)
  end

  def p(games_count = @record.length)
    p1_wins = @record.count(&:zero?)
    super(p1_wins, games_count - p1_wins)
  end
end
