RSpec.describe CodebreakerConsole do
  let(:console) { described_class.new }
  let(:commands) { described_class::COMMANDS }

  let(:code) { console.game.code.join }
  let(:test_code) { [1, 2, 3, 4] }
  let(:win_result) { console.game.class::WIN_RESULT }
  let(:hint_code_matcher) { /^[1-6]{1}$/ }

  let(:valid_username) { 'username' }
  let(:invalid_username) { 'zz' }

  let(:valid_difficulties) { console.game.class::DIFFICULTIES.keys.map(&:to_s) }
  let(:invalid_difficulty) { 'invalid_difficulty' }

  context 'when #registration method is called' do
    it 'calls #set_username' do
      expect(console).to receive(:set_username)
      console.send(:registration)
    end

    it 'calls #set_difficulty only if username is set' do
      console.game.username = valid_username
      expect(console).to receive(:set_difficulty)
      console.send(:registration)
    end
  end

  context 'when #set_username method is called' do
    it 'sets valid username' do
      allow(console).to receive(:gets).and_return(valid_username)
      console.send(:set_username)
      expect(console.game.username).to eq(valid_username)
    end

    it "doesn't sets invalid username" do
      allow(console).to receive(:gets).and_return(invalid_username)
      expect { console.send(:set_username) }.to output(Messages.invalid_username).to_stdout
      expect(console.game.username).to be_nil
    end
  end

  context 'when #set_difficulty method is called' do
    it 'sets valid difficulty' do
      valid_difficulties.each do |valid_difficulty|
        allow(console).to receive(:gets).and_return(valid_difficulty)
        console.send(:set_difficulty)
        expect(console.game.difficulty.to_s).to eq(valid_difficulty)
      end
    end

    it "doesn't set invalid difficulty" do
      allow(console).to receive(:gets).and_return(invalid_difficulty)
      expect { console.send(:set_difficulty) }.to output(Messages.set_difficulty).to_stdout
      expect(console.game.difficulty).to be_nil
    end
  end

  context 'when main loop starts' do
    it do
      allow(console).to receive(:loop)
      console.init
    end
  end

  context 'when #init method is called' do
    before do
      allow(console).to receive(:loop).and_yield
    end

    it 'calls #new_game when game state is :new' do
      expect(console.game.state).to eq(:new)
      allow(console).to receive(:gets).and_return(commands[:start])
      expect { console.init }.to output(Messages.welcome).to_stdout
    end

    it 'calls #start when game state is :started' do
      console.game.start
      allow(console).to receive(:gets).and_return('user1')
      expect { console.init }.to output(Messages.set_username).to_stdout
    end

    it 'calls #save_results and #new_game when game state is :win' do
      console.game.start
      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.send(:set_difficulty)
      console.game.send(:win)

      allow(console).to receive(:gets).and_return('user1')
      expect { console.init }.to output(Messages.win(code)).to_stdout
    end

    it 'calls #new_game when game state is :game_over' do
      console.game.start
      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.send(:set_difficulty)
      console.game.send(:game_over)

      allow(console).to receive(:gets).and_return('user1')
      expect { console.init }.to output(Messages.game_over(code)).to_stdout
    end
  end

  context 'when #new_game method is called' do
    before do
      allow(console).to receive(:loop).and_yield
      console.game.new_game

      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.send(:set_difficulty)
    end

    it "starts the game on 'start' command" do
      allow(console).to receive(:gets).and_return(commands[:start])
      expect { console.init }.to output(Messages.welcome).to_stdout
      expect(console.game.state).to eq(:started)
    end

    it "displays game rules on 'rules' command" do
      allow(console).to receive(:gets).and_return(commands[:rules])
      expect { console.init }
        .to output(Messages.rules).to_stdout
    end

    it "displays game stats on 'stats' command" do
      allow(console).to receive(:gets).and_return(commands[:stats])
      expect { console.init }.to output(Statistics.show).to_stdout
    end

    it "exits on 'exit' command" do
      allow(console).to receive(:gets).and_return(commands[:exit])
      expect { console.init }.to output(Messages.exit_game).to_stdout.and raise_error(SystemExit)
    end

    it 'displays proper message on unexpected command' do
      allow(console).to receive(:gets).and_return('unexpected command')
      expect { console.init }.to output(Messages.unknown_command).to_stdout
    end
  end

  context 'when #start method is called' do
    before do
      allow(console).to receive(:loop).and_yield
      console.game.start
      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.send(:set_difficulty)
    end

    it 'calls #registration' do
      expect(console).to receive(:registration)
      console.init
    end

    it "displays one digit from secret code on 'hint' command" do
      allow(console).to receive(:gets).and_return(commands[:hint])
      expect { console.init }.to output(hint_code_matcher).to_stdout
    end

    it 'displays result when guess code' do
      console.game.instance_variable_set(:@code, test_code)
      allow(console).to receive(:gets).and_return('1234')
      expect { console.init }.to output(/#{Regexp.quote(win_result)}/).to_stdout
    end

    it "exits on 'exit' command" do
      allow(console).to receive(:gets).and_return(commands[:exit])
      expect { console.init }.to output(Messages.exit_game).to_stdout.and raise_error(SystemExit)
    end
  end

  context 'when #save_results method is called' do
    it 'saves results' do
      allow(console).to receive(:loop).and_yield
      console.game.start
      console.game.username = valid_username
      allow(console).to receive(:gets).and_return(valid_difficulties.first)
      console.send(:set_difficulty)
      console.game.send(:win)
      allow(console).to receive(:gets).and_return(commands[:yes])
      expect { console.init }.to output(Messages.results_saved).to_stdout
    end
  end

  context 'when #exit_game method is called' do
    it 'exits game' do
      expect { console.send(:exit_game) }.to output(Messages.exit_game).to_stdout.and raise_error(SystemExit)
    end
  end
end
