RSpec.describe CodebreakerConsole do
  let(:console) { described_class.new }

  let(:valid_username) { 'username' }
  let(:invalid_username) { 'zz' }

  let(:valid_difficulties) { ['easy', 'medium', 'hell'] }
  let(:invalid_difficulty) { 'invalid_difficulty' }


  context '#registration' do
    it 'calls #set_username' do
      expect(console).to receive(:set_username)
      console.registration
    end

    it 'calls #set_difficulty only if username is set' do
      console.game.username = valid_username
      expect(console).to receive(:set_difficulty)
      console.registration
    end
  end

  context '#set_username' do
      it 'sets valid username' do
        allow(console).to receive(:gets).and_return(valid_username)
        console.set_username
        expect(console.game.username).to eq(valid_username)
      end

      it "doesn't sets invalid username" do
        allow(console).to receive(:gets).and_return(invalid_username)
        expect { console.set_username }.to output(/Please, enter correct name. \nIt should be from 3 to 20 symbols long.\n/).to_stdout
        expect(console.game.username).to be_nil
      end
  end

  context '#set_difficulty' do
      it 'sets valid difficulty' do
        valid_difficulties.each do |valid_difficulty|  
          allow(console).to receive(:gets).and_return(valid_difficulty)
          console.set_difficulty
          expect(console.game.difficulty).to eq(valid_difficulty)
        end
      end

      it "doesn't sets invalid difficulty" do
        allow(console).to receive(:gets).and_return(invalid_difficulty)
        expect { console.set_difficulty }.to output(/Please, enter game difficulty/).to_stdout
        expect(console.game.difficulty).to be_nil
      end
  end

  context '#init' do
    it 'starts main loop' do
      allow(console).to receive(:loop)
      console.init
    end
  end

  context '#run' do
    it "calls #new_game when game state is :new" do
      expect(console.game.state).to eq(:new)
      allow(console).to receive(:gets).and_return('start')
      expect { console.run }.to output(/Please, enter your name/).to_stdout
    end

    it "calls #start when game state is :started" do
      console.game.start
      allow(console).to receive(:gets).and_return('user1')
      expect { console.run }.to output(/Please, enter your name/).to_stdout
    end

    it "calls #save_results and #new_game when game state is :win" do
      console.game.start
      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.set_difficulty
      console.game.win

      allow(console).to receive(:gets).and_return('user1')
      expect { console.run }.to output(/Congratulations, you guessed the code/).to_stdout
    end

    it "calls #new_game when game state is :game_over" do
      console.game.start
      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.set_difficulty
      console.game.game_over

      allow(console).to receive(:gets).and_return('user1')
      expect { console.run }.to output(/Sorry, you didn't guess the code/).to_stdout
    end   
  end

  context '#new_game' do
    before(:each) do
      console.game.new_game

      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.set_difficulty
    end

    it "starts the game on 'start' command" do
      allow(console).to receive(:gets).and_return('start')
      expect { console.new_game }.to output("Please, enter 'start' to start new game,\n'rules' " \
                                            "to read game rules,\n'stats' to display high scores,\n'exit' " \
                                            "to exit the game.\nPlease, enter your name\n").to_stdout
    end

    it "displays game rules on 'rules' command" do
      allow(console).to receive(:gets).and_return('rules')
      expect { console.new_game }
        .to output("Please, enter 'start' to start new game,\n'rules' " \
                   "to read game rules,\n'stats' to display high scores,\n'exit' " \
                   "to exit the game.\n" \
                   "---------------------------------\n" \
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
                   "---------------------------------\n").to_stdout
    end

    it "displays game stats on 'stats' command" do
      allow(console).to receive(:gets).and_return('stats')
      expect { console.new_game }.to output(/Name, Difficulty, Attempts Total, Attempts Used, Hints Total, Hints Used/).to_stdout
    end

    it "exits on 'exit' command" do
      allow(console).to receive(:gets).and_return('exit')
      expect { console.new_game }.to output(/Thanks for playing our game!\n/).to_stdout.and raise_error(SystemExit)
    end

    it "displays proper message on unexpected command" do
      allow(console).to receive(:gets).and_return('unexpected command')
      expect { console.new_game }.to output(/You have passed an unexpected command./).to_stdout
    end    
  end

  context '#start' do
    before(:each) do
      console.game.start
      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.set_difficulty
    end

    it 'calls #registration' do
      expect(console).to receive(:registration)
      console.start
    end

    it "displays one digit from secret code on 'hint' command" do
      allow(console).to receive(:gets).and_return('hint')
      expect { console.start }.to output(/^[1-6]{1}$/).to_stdout
    end

    it "displays result when guess code" do
      allow(console).to receive(:gets).and_return('1234')
      expect { console.start }.to output(/^Please, enter the code\n[+-]*\n$/).to_stdout
    end    

    it "exits on 'exit' command" do
      allow(console).to receive(:gets).and_return('exit')
      expect { console.start }.to output(/Thanks for playing our game!\n/).to_stdout.and raise_error(SystemExit)
    end
  end

  context '#rules' do  
    it 'displays game rules' do
      expect { console.rules }
        .to output("---------------------------------\n" \
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
                   "---------------------------------\n").to_stdout
    end
  end

  context '#save_results' do  
    it 'saves results' do
      console.game.start
      allow(console).to receive(:gets).and_return('yes')
      expect { console.save_results }.to output(/Your results have been saved./).to_stdout
    end
  end  

  context '#exit_game' do  
    it 'exits game' do
      expect { console.exit_game }.to output(/Thanks for playing our game!\n/).to_stdout.and raise_error(SystemExit)
    end
  end
end
