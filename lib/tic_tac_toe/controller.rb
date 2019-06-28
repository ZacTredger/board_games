%w[../controller_turn_based.rb ../additive_state_controller.rb
   ../series_turn_based.rb ../additive_state_series.rb series.rb
   ../additive_state_game.rb game.rb
   board.rb].each { |filename| require_relative(filename) }

# Controls tic-tac-toe series
class TicTacToe < Additive
  def initialize
    setup(TicTacToeSeries)
  end
end

if /main\.rb$/.match? $PROGRAM_NAME
  controller = TicTacToe.new
  end_series ||= controller.do_a_round until end_series
end
