RSpec.describe CodebreakerConsole do
  let(:console) { described_class.new }
  let(:code) { console.game.code.join }

  let(:valid_username) { 'username' }
  let(:invalid_username) { 'zz' }

  let(:valid_difficulties) { %w[easy medium hell] }
  let(:invalid_difficulty) { 'invalid_difficulty' }

  context 'when #registration method is called' do
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

  context 'when #set_username method is called' do
    it 'sets valid username' do
      allow(console).to receive(:gets).and_return(valid_username)
      console.set_username
      expect(console.game.username).to eq(valid_username)
    end

    it "doesn't sets invalid username" do
      allow(console).to receive(:gets).and_return(invalid_username)
      expect { console.set_username }.to output(Messages.invalid_username).to_stdout
      expect(console.game.username).to be_nil
    end
  end

  context 'when #set_difficulty method is called' do
    it 'sets valid difficulty' do
      valid_difficulties.each do |valid_difficulty|
        allow(console).to receive(:gets).and_return(valid_difficulty)
        console.set_difficulty
        expect(console.game.difficulty).to eq(valid_difficulty)
      end
    end

    it "doesn't set invalid difficulty" do
      allow(console).to receive(:gets).and_return(invalid_difficulty)
      expect { console.set_difficulty }.to output(Messages.set_difficulty).to_stdout
      expect(console.game.difficulty).to be_nil
    end
  end

  context 'when #init method is called' do
    it 'starts main loop' do
      allow(console).to receive(:loop)
      console.init
    end
  end

  context 'when #run method is called' do
    it 'calls #new_game when game state is :new' do
      expect(console.game.state).to eq(:new)
      allow(console).to receive(:gets).and_return('start')
      expect { console.run }.to output(Messages.set_username).to_stdout
    end

    it 'calls #start when game state is :started' do
      console.game.start
      allow(console).to receive(:gets).and_return('user1')
      expect { console.run }.to output(Messages.set_username).to_stdout
    end

    it 'calls #save_results and #new_game when game state is :win' do
      console.game.start
      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.set_difficulty
      console.game.win

      allow(console).to receive(:gets).and_return('user1')
      expect { console.run }.to output(Messages.win(code)).to_stdout
    end

    it 'calls #new_game when game state is :game_over' do
      console.game.start
      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.set_difficulty
      console.game.game_over

      allow(console).to receive(:gets).and_return('user1')
      expect { console.run }.to output(Messages.game_over(code)).to_stdout
    end
  end

  context 'when #new_game method is called' do
    before do
      console.game.new_game

      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.set_difficulty
    end

    it "starts the game on 'start' command" do
      allow(console).to receive(:gets).and_return('start')
      expect { console.new_game }.to output(Messages.welcome).to_stdout
    end

    it "displays game rules on 'rules' command" do
      allow(console).to receive(:gets).and_return('rules')
      expect { console.new_game }
        .to output(Messages.rules).to_stdout
    end

    it "displays game stats on 'stats' command" do
      allow(console).to receive(:gets).and_return('stats')
      expect { console.new_game }.to output(Statistics.show).to_stdout
    end

    it "exits on 'exit' command" do
      allow(console).to receive(:gets).and_return('exit')
      expect { console.new_game }.to output(Messages.exit_game).to_stdout.and raise_error(SystemExit)
    end

    it 'displays proper message on unexpected command' do
      allow(console).to receive(:gets).and_return('unexpected command')
      expect { console.new_game }.to output(Messages.unknown_command).to_stdout
    end
  end

  context 'when #start method is called' do
    before do
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

    it 'displays result when guess code' do
      allow(console).to receive(:gets).and_return('1234')
      expect { console.start }.to output(Messages.start_game).to_stdout
    end

    it "exits on 'exit' command" do
      allow(console).to receive(:gets).and_return('exit')
      expect { console.start }.to output(Messages.exit_game).to_stdout.and raise_error(SystemExit)
    end
  end

  context 'when #save_results method is called' do
    it 'saves results' do
      console.game.start
      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.set_difficulty
      console.game.win
      allow(console).to receive(:gets).and_return('yes')
      expect { console.save_results }.to output(Messages.results_saved).to_stdout
    end
  end

  context 'when #exit_game method is called' do
    it 'exits game' do
      expect { console.exit_game }.to output(Messages.exit_game).to_stdout.and raise_error(SystemExit)
    end
  end
end
