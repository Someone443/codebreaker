module Output

  def init_message
    puts "Welcome to Codebreaker game."
  end

  def welcome_message
    puts "Please, enter 'start' to start new game,\n" \
         "'rules' to read game rules,\n" \
         "'stats' to display high scores,\n" \
         "'exit' to exit the game."
  end

  def start_game_message
    puts "Please, enter the code"
  end

  def set_username_message
    puts 'Please, enter your name'
  end

  def invalid_username_message
    puts "Please, enter correct name. \n" \
         "It should be from 3 to 20 symbols long."
  end

  def set_difficulty_message
    puts "Please, enter game difficulty: \n" \
         "'easy' - 15 attempts, 2 hints \n" \
         "'medium' - 10 attempts, 1 hint \n" \
         "'hell' - 5 attempts, 1 hint"
  end

  def win_message(code)
    puts "Congratulations, you guessed the code #{code}!"
  end

  def game_over_message(code)
    puts "Sorry, you didn't guess the code #{code} this time. Try again?"
  end

  def save_results_message
    puts "Would you like to save results?"
  end

  def results_saved_message
     puts "Your results have been saved."
  end

  def exit_game_message
     puts 'Thanks for playing our game!'
  end

  def unknown_command_message
    puts 'You have passed an unexpected command.'
  end

  def rules_text
    puts "---------------------------------\n" \
         "Codebreaker is a logic game in which a code-breaker tries to break a secret code \n" \
         "created by a code-maker. The codemaker creates a secret code of four numbers between 1 and 6. \n" \
         "The codebreaker gets some number of chances to break the code (depends on chosen difficulty). \n" \
         "In each turn, the codebreaker makes a guess of 4 numbers. The codemaker then \n" \
         "marks the guess with up to 4 signs - '+' or '-' or empty spaces.\n" \
         "A '+' indicates an exact match: one of the numbers in the guess is the same as one of the numbers \n" \
         "in the secret code and in the same position. For example:\n" \
         "Secret number - 1234\n" \
         "Input number - 6264\n" \
         "Number of pluses - 2 (second and fourth position)\n" \
         "A '-' indicates a number match: one of the numbers in the guess is the same as one of the numbers \n" \
         "in the secret code but in a different position. For example:\n" \
         "Secret number - 1234\n" \
         "Input number - 6462\n" \
         "Number of minuses - 2 (second and fourth position)\n" \
         "An empty space indicates that there is not a current digit in a secret number.\n" \
         "If codebreaker inputs the exact number as a secret number - codebreaker wins the game. \n" \
         "If all attempts are spent - codebreaker loses.\n" \
         "Codebreaker also has some number of hints(depends on chosen difficulty). \n" \
         "If a user takes a hint - he receives back a separate digit of the secret code.\n" \
         "---------------------------------"
  end
end
