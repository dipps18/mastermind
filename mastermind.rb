require 'pry'
module Display
  def display_welcome
    puts "Welcome to Mastermind\n"
    puts "Please select from one of the options below (1-3)\n"
    puts "1. Display Rules"
    puts "2. Choose to be Code Maker"
    puts "3. Choose to be Code Breaker" 
  end

  def display_rules
    puts "Rules credit: https://replit.com/@rlmoser/rubyMastermind#README.md\n
    How to play Mastermind:\n
    You can choose to be the code maker or the code breaker\n
    This is a 1-player game against the computer.\n
    There are six different number combinations:\n
    The code maker will choose four to create a 'master code'. For example,\n
    1341\n
    As you can see, there can be more then one of the same number/color.\n
    In order to win, the code breaker needs to guess the 'master code' in 12 or less turns.\n


    Clues:\n
    After each guess, there will be up to four clues to help crack the code.\n

    ● This clue means you have 1 correct number in the correct location.\n
    ○ This clue means you have 1 correct number, but in the wrong location.\n

    Clue Example:\n
    To continue the example, using the above 'master code' a guess of 1463 would produce 3 clues:\n
    1     4     6     3     Clues: ● ○ ○ \n
    The guess had 1 correct number in the correct location [1] and 2 correct numbers in a wrong location [3,4].\n"
  end

  def display_error(choice)
    puts "#{choice} is not a valid option"
  end

  def display_digit_error
    puts "digits should range from 1-6"
  end

  def display_code_generation_message
    puts 'The computer has created a 4 digit code from with digits ranging from 1-6'
  end

  def display_turns_left(turns)
    puts "\n#{turns} turns left\n"
  end

  def prompt_guess
    puts "Enter your guess >> "
  end

  def display_correct_number_and_position(count)
    count.times{print "● "}
  end

  def display_correct_number(count)
    count.times{print "○ "}
  end

  def display_results(code)
    puts @turns == 0 ? "You lose, the code was #{code}" : "You win!"
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
      if choice == '1'
        display_rules
      elsif choice == '2'
        player = CodeMaker.new
        play_as_code_maker(player)
        break
      elsif choice == '3'
        player = CodeBreaker.new
        play_as_code_breaker(player)
        break
      else
        display_choice_error(choice)
      end
    end
  end

  def play_as_code_breaker(player)
    computer = CodeSetter.new()
    computer.code = generate_code
    display_code_generation_message
    loop do
      break if gameover?(player)
      player.correct_number_only = 0
      player.correct_number_and_position = 0
      display_turns_left(@turns)
      prompt_guess
      player.guess = get_input
      if invalid_input?(player.guess)
        puts display_digit_error
      else
        @turns -= 1
        compare_codes(computer, player)
        display_clues(player.correct_number_and_position, player.correct_number_only)
      end
    end
    display_results(computer.code)
  end

  def play_as_code_maker
    def update_possible_sequences(sequence_list, guess, exact_correct, correct_numbers)
      arr = [0, 1, 2, 3].permutation(exact_correct).to_a # gives the permutation of the indices when 2 correct guesses are in correct position
      must_contain = guess.permutation(exact_correct + correct_numbers).to_a
      new_arr=[]        
      sequence_list.each do |element|
         arr.each do |combo| 
          if exact_correct == 2

            if element[combo[0]] == guess[combo[0]] && element[combo[1]] == guess[combo[1]] && must_contain.any?{|arr| (arr - element).empty?}
              new_arr.push(element)
              break
            end
          end
        end
      end
      new_arr
    end
  end

  def generate_code
    code = []
    for i in 0..3
      code[i] = (Random.new).rand(1..6)
    end
    code
  end
  
  def invalid_input?(guess)
    guess.any?{|element| element < 1 || element > 6 || guess.length < 4 }
  end

  def gameover?(player)
    player.correct_number_and_position == 4 || @turns == 0 ? true : false
  end

  def get_input
    gets.chomp.split("").map{|element| element.to_i}
  end

  def compare_codes(computer, player)
    common_digits_count = 0
    unique_code = computer.code.dup # this variable stores the value of unique code and removes identical elements at each iteration
    for i in 0..3
      player.correct_number_and_position += 1 if computer.code[i] == player.guess[i]
      unique_code.include?(player.guess[i]) ? common_digits_count += 1 : next
      unique_code.delete_at(unique_code.index(player.guess[i]) || unique_code.length)
    end
    player.correct_number_only = common_digits_count - player.correct_number_and_position
  end

  def display_clues(correct_number_and_position, correct_number_only)
    display_correct_number_and_position(correct_number_and_position)
    display_correct_number(correct_number_only)
  end
end

class CodeBreaker
  attr_accessor :guess, :correct_number_and_position, :correct_number_only
  def initialize
    @correct_number_and_position = 0
    @correct_number_only = 0
  end
end

class CodeSetter
  attr_accessor :code
end

game = Game.new()
game.play_game

