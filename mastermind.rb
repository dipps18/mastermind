# frozen_string_literal: true

require 'colorize'
module Display
  def display_welcome
    puts "Welcome to Mastermind\n"
    puts "Please select from one of the options below (1-3)\n"
    puts '1. Display Rules'
    puts '2. Choose to be Code Maker'
    puts '3. Choose to be Code Breaker'
  end

  def display_rules
    puts "
    How to play Mastermind:
    You can choose to be the code maker or the code breaker
    This is a 1-player game against the computer.
    There are six different number combinations:
    The code maker will choose four to create a 'master code'. For example,
    1341
    As you can see, there can be more then one of the same number/color.
    In order to win, the code breaker needs to guess the 'master code' in 12 or less turns.
    Clues:
    After each guess, there will be up to four clues to help crack the code.
    ● This clue means you have 1 correct number in the correct location.
    ○ This clue means you have 1 correct number, but in the wrong location.
    Clue Example:
    To continue the example, using the above 'master code' a guess of 1463 would produce 3 clues:
    1463  ● ○ ○
    The guess had 1 correct number in the correct location [1] and 2 correct numbers in a wrong location [3,4].\n"
  end

  def display_choice_error(choice)
    puts "#{choice} is not a valid option\nPlease select again".red
  end

  def display_digit_error
    puts "digits should range from 1-6\nPlease renter a new code".red
  end

  def display_code_generation_message
    puts "\nThe computer has created a 4 digit code from with digits ranging from 1-6".green
  end

  def display_turns_left(turns)
    puts "\n#{turns} turns left"
  end

  def prompt_guess
    print 'Enter your guess >> '.green
  end

  def prompt_code
    print "\nEnter your code >> ".green
  end

  def display_correct_number_and_position(count)
    count.times { print '● '.blue }
  end

  def display_correct_number(count)
    count.times { print '○ ' }
    print "\n"
  end

  def display_results(code, guess)
    puts code == guess ? "\nCode breaker wins!".green : "Code breaker loses, the code was #{code}".red
  end

  def display_computer_guess(guess)
    print "Computer guess: #{guess.join}    "
  end
end

class Game
  include Display
  def initialize
    @turns = 12
    @gameover = false
  end

  def play_game
    loop do
      display_welcome
      choice = gets.chomp[0]
      case choice
      when '1'
        display_rules
      when '2'
        play_as_code_maker
        break
      when '3'
        play_as_code_breaker
        break
      else
        display_choice_error(choice)
      end
    end
  end

  def play_as_code_breaker
    player = CodeBreaker.new
    computer = CodeSetter.new
    computer.code = generate_code
    display_code_generation_message
    loop do
      display_turns_left(@turns)
      prompt_guess
      @turns -= 1 if player.guess = ret_correct_input
      cur_score = compare_codes(computer.code, player.guess)
      display_clues(cur_score[0], cur_score[1])
      break if gameover?(cur_score[0])
    end
    display_results(computer.code, player.guess)
  end

  def update_possible_sequences(possible_sequences, guess, cur_score)
    possible_sequences.delete_if do |code|
      true if compare_codes(guess, code) != cur_score
    end
  end

  def initial_guess
    '1122'.split('').map(&:to_i)
  end

  def play_as_code_maker
    player = CodeSetter.new
    computer = CodeBreaker.new
    prompt_code
    player.code = ret_correct_input
    computer.guess = initial_guess
    possible_sequences = [1, 2, 3, 4, 5, 6].repeated_permutation(4).to_a
    loop do
      display_turns_left(@turns)
      display_computer_guess(computer.guess)
      @turns -= 1
      cur_score = compare_codes(player.code, computer.guess)
      display_clues(cur_score[0], cur_score[1])
      update_possible_sequences(possible_sequences, computer.guess, cur_score)
      break if computer.guess == player.code || @turns.zero?

      computer.guess = possible_sequences.sample
    end
    display_results(player.code, computer.guess)
  end

  def generate_code
    code = []
    (0..3).each do |i|
      code[i] = (Random.new).rand(1..6)
    end
    code
  end

  def invalid_input?(guess)
    guess.any? { |element| element < 1 || element > 6 || guess.length < 4 }
  end

  def gameover?(correct_number_and_position)
    correct_number_and_position == 4 || @turns.zero? ? true : false
  end

  def ret_correct_input
    input = 0
    loop do
      input = gets.chomp.split('').map(&:to_i)
      invalid_input?(input) ? display_digit_error : break
    end
    input
  end

  def compare_codes(code, guess)
    common_digits_count = 0
    correct_number_and_position = 0
    unique_code = code.dup
    (0..3).each do |i|
      correct_number_and_position += 1 if code[i] == guess[i]
      unique_code.include?(guess[i]) ? common_digits_count += 1 : next
      unique_code.delete_at(unique_code.index(guess[i]) || unique_code.length)
    end
    correct_number_only = common_digits_count - correct_number_and_position
    [correct_number_and_position, correct_number_only]
  end

  def display_clues(correct_number_and_position, correct_number_only)
    display_correct_number_and_position(correct_number_and_position)
    display_correct_number(correct_number_only)
  end
end

class CodeBreaker
  attr_accessor :guess
end

class CodeSetter
  attr_accessor :code
end

loop do
  game = Game.new
  game.play_game
  puts 'Do you wish to play again ? (yes or no)'
  ans = gets.chomp
  break if ans == 'no'
end

puts 'Thanks for playing'
