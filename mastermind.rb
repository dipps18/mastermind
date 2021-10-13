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
        play_as_code_maker()
        break
      elsif choice == '3'
        play_as_code_breaker()
        break
      else
        display_choice_error(choice)
      end
    end
  end

  def play_as_code_breaker()
    player = CodeBreaker.new
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

  def update_possible_sequences(possible_sequences, guess, exact_correct, correct_numbers)
    indices = [0, 1, 2, 3].permutation(exact_correct).to_a # gives the permutation of the indices when 2 correct guesses are in correct position
    must_contain = guess.permutation(exact_correct + correct_numbers).to_a
    updated_possible_sequences=[]        
    possible_sequences.each do |element|
      if exact_correct > 0  
        indices.each do |index|
          if (must_contain.any?{|arr| (arr - element).empty?}) 
            if (element[index[0]] == guess[index[0]] && exact_correct == 1) || (element[index[0]] == guess[index[0]] && element[index[1]] == guess[index[1]] && exact_correct == 2) || (element[index[0]] == guess[index[0]] && element[index[1]] == guess[index[1]] && element[index[2]] == guess[index[2]] && exact_correct == 3)
              updated_possible_sequences.push(element)
              break
            end
          end
        end
      else
        updated_possible_sequences.push(element) if must_contain.any?{|arr| (arr - element).empty?} 
      end
    end
    updated_possible_sequences
  end

  def play_as_code_maker
    player = CodeSetter.new
    computer = CodeBreaker.new
    puts "Input your code >> "
    player.code = get_input
    computer.guess = "1122".split("").map{|element| element.to_i}
    possible_sequences = [1, 2, 3, 4, 5, 6].repeated_permutation(4)
    updated_seq = update_possible_sequences(possible_sequences, computer.guess, computer.correct_number_and_position, computer.correct_number_only)
    loop do 
      computer.correct_number_and_position = 0
      computer.correct_number_only = 0
      puts "Computer guess: #{computer.guess}"
      compare_codes(player, computer)
      display_clues(computer.correct_number_and_position, computer.correct_number_only)
      updated_seq = update_possible_sequences(updated_seq, computer.guess, computer.correct_number_and_position, computer.correct_number_only)
      break if computer.guess == player.code || @turns == 0
      computer.guess = updated_seq.sample
      puts updated_seq.length
      @turns -= 1
    end  
    display_results(player.code)
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

  def compare_codes(code_setter, code_breaker)
    common_digits_count = 0
    unique_code = code_setter.code.dup # this variable stores the value of unique code and removes identical elements at each iteration
    for i in 0..3
      code_breaker.correct_number_and_position += 1 if code_setter.code[i] == code_breaker.guess[i]
      unique_code.include?(code_breaker.guess[i]) ? common_digits_count += 1 : next
      unique_code.delete_at(unique_code.index(code_breaker.guess[i]) || unique_code.length)
    end
    code_breaker.correct_number_only = common_digits_count - code_breaker.correct_number_and_position
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

