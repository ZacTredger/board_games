# frozen_string_literal: true

# Create series of games where they take turns
class TurnBasedSeries < Series
  def take_turn(which)
    midgame_data = @game.move(@names[which], which)
    return save_game(midgame_data) if midgame_data.is_a? Hash

    game_over?(which)
  end

  def p(games_count = @record.length)
    p1_ws = @record.count(&:zero?)
    super(p1_ws, games_count - p1_ws)
  end

  def choose_secret(_nil)
    nil
  end
end
