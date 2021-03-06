# Root of a sub-tree of TTT game states
class TTTGameState < GameState
  include OtherID

  private

  def childs_frees(parents_frees, latest_move)
    parents_frees - [latest_move]
  end
end

# State as AI moves; has child for each free cell (& corresponding user move)
class TTTAIMovedState < TTTGameState
  include AIMovedState

  private

  # Create a child game-state for every free cell
  def create_children(free_positions)
    super(free_positions, TTTUserMovedState)
  end
end

# State as user moves; will have one child: the best AI move once evaluated
class TTTUserMovedState < TTTGameState
  include UserMovedState

  private

  def replicate_latest_move
    @board.move(@latest_move, other(@ai_id))
  end

  # Create a child game-state for every free cell
  def create_children(free_positions)
    super(free_positions, TTTAIMovedState)
  end
end
