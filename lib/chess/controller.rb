require 'matrix'
%w[piece.rb board.rb graveyard.rb game.rb ../series_turn_based.rb
   series.rb ../controller_turn_based.rb ].each { |f| require_relative(f) }

# Controls Chess series. Only PvP.
class Chess < TurnBased
  def initialize
    setup(ChessSeries)
  end

  private

  def create_series(s_class)
    super(s_class)
  end

  def whose_go
    @midgame ? @midgame ^ 1 : @id_of_leader
  end
end

if /main\.rb$/.match? $PROGRAM_NAME
  controller = Chess.new
  end_series ||= controller.do_a_round until end_series
end