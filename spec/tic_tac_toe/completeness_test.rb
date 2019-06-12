require 'stringio'
require 'o_stream_catcher'
require 'json'
require 'date'

require_relative '../../lib/series_root.rb'
require_relative '../../lib/series_turn_based.rb'
require_relative '../../lib/tic_tac_toe/series.rb'
require_relative '../../lib/tic_tac_toe/game.rb'
require_relative '../../lib/tic_tac_toe/p_v_c_game.rb'
require_relative '../../lib/tic_tac_toe/board.rb'
require_relative '../../lib/tic_tac_toe/lines.rb'
require_relative 'helpers.rb'

# Create one game class with tester leading, one with AI leading. Save results
class TestTicTacToe
  def run_tests
    first = play(TestAILeadSeries.new)
    second = play(TestAIFollowSeries.new)
    data_hash = hashify(first, second)
    save_data(data_hash)
  end

  private

  def play(series)
    # Keep taking turns until series' stack is empty. Then exit
    (series_record ||= series.take_turn) until series_record
    series_record
  end

  def hashify(ai_first_results, ai_second_results)
    commit_keys = %w[id author date comment]
    commit_arr =
      `git log -n1`.split("\n").reject(&:empty?).map { |x| x.sub(/\S*\s+/, '') }
    {
      'commit' => Hash[(0..3).to_a.map { |i| [commit_keys[i], commit_arr[i]] }],
      'ai_first_results' => ai_first_results,
      'ai_second_results' => ai_second_results
    }
  end

  def save_data(data)
    file = __dir__ + '/opti.json'
    saved = File.exist?(file) ? JSON.parse(File.read(file)) : {}
    saved[Time.now.strftime('%d/%m/%Y %H:%M')] = data
    File.write(file, saved.to_json)
    saved
  end
end

# Create a stack of games and make every possible move on each go.
class TestTicTacToeSeries < TicTacToeSeries
  def initialize(game)
    @record = { 'ai_wins' => 0, 'draws' => 0, 'ai_losses' => 0 }
    @game_stack = []
    jump_the_queue(game)
  end

  def take_turn
    game, cell = @game_stack.pop
    $stdin = write_string_io(cell)
    game_over = turn(game, 'tester', @id)
    $stdin = STDIN
    (game_over = turn(game, 'ai', other(@id))) unless game_over
    if game_over
      @record[game_over] += 1
      return (@game_stack.empty? ? @record : nil)
    end
    jump_the_queue(game)
  end

  private

  def turn(game, who, id)
    result = OStreamCatcher.catch do
      game.move(who)
      game.game_over?(who, id)
    end[0]
    game_over?(result)
  end

  def write_string_io(cell)
    string_io = StringIO.new
    string_io.puts(cell + 1)
    string_io.rewind
    string_io
  end

  def game_over?(result)
    case result
    when false
      false
    when @id
      'ai_losses'
    when 2
      'draws'
    else
      'ai_wins'
    end
  end

  # Push 'e' games onto game-stack, where e = number of empty cells.
  # Popping from stack traverses game-tree depth-first, so
  # max stack length is O(n^2) (vs O(n^n) for breadth-first)
  def jump_the_queue(game)
    board = game.instance_variable_get(:@board)
    cells =
      board.each_with_index.with_object([]) { |(v, i), a| a << i if v.zero? }
    cells.each { |cell| @game_stack.push([game.deep_clone, cell]) }
    false
  end

  def other(id)
    (id - 3)**2
  end
end

# AI moves first before stack is initially populated
class TestAILeadSeries < TestTicTacToeSeries
  def initialize
    @id = 4
    game = nil
    OStreamCatcher.catch do
      game = AILead.new
      game.move('ai')
    end
    super(game)
  end
end

# Initially populate stack with fresh game and all possible first tester moves
class TestAIFollowSeries < TestTicTacToeSeries
  def initialize
    @id = 1
    game = nil
    OStreamCatcher.catch do
      game = AIFollow.new
    end
    super(game)
  end
end