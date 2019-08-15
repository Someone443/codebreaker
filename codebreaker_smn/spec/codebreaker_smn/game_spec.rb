require 'spec_helper'

RSpec.describe CodebreakerSmn::Game do
  let(:game) { described_class.new }
  let(:game_difficulties) { game.class::DIFFICULTIES }
  let(:hinted_digit) { game.get_hint }

  let(:game_code) { [1, 2, 3, 4] }
  let(:win_guess) { '1234' }
  let(:invalid_guesses) { ['', 'zz', '123', '11234', '7890', Object] }

  let(:valid_username) { 'valid_username' }
  let(:invalid_username) { 'qz' }  
  let(:valid_difficulty) { game_difficulties.keys.sample }
  let(:invalid_difficulty) { 'zz' }

  before do
    game.new_game
    game.start
    game.username = valid_username
    game.difficulty = valid_difficulty
  end

  context 'with #start' do
    it 'generates secret code' do
      expect(game.code).not_to be_empty
    end

    it 'saves secret code with size from code rules' do
      expect(game.code.size).to eq(described_class::CODE_RULES[:size])
    end

    it 'saves secret code with numbers from code rules' do
      game.code.each do |digit|
        expect(described_class::CODE_RULES[:digits]).to include(digit)
      end
    end
  end

  context 'with #guess_code' do
    context 'when validates user guess' do
      it 'with valid guess' do
        game.instance_variable_set(:@code, game_code)
        expect(game.guess_code(win_guess)).to eq(described_class::WIN_RESULT)
      end

      it 'with invalid guess' do
        game.instance_variable_set(:@code, game_code)
        invalid_guesses.each do |invalid_guess|
          expect(game.guess_code(invalid_guess)).to be_nil
        end
      end
    end

    context 'when processes user guesses' do
      let(:examples) do
        [
          { code: [6, 5, 4, 3], inputs: %w[5643 6411 6544 3456 6666 2666 2222],
            expected_results: ['++--', '+-', '+++', '----', '+', '-', ''] },
          { code: [6, 6, 6, 6], inputs: ['1661'],
            expected_results: ['++'] },
          { code: [1, 2, 3, 4], inputs: %w[3124 1524 1234],
            expected_results: ['+---', '++-', '++++'] },
          { code: [1, 4, 5, 5], inputs: ['5133'],
            expected_results: ['--'] }
        ]
      end

      it 'from examples' do
        examples.each do |example|
          game.start
          game.username = valid_username
          game.difficulty = valid_difficulty
          game.instance_variable_set(:@code, example[:code])

          example[:inputs].each_with_index do |input, index|
            expect(game.guess_code(input)).to eq(example[:expected_results][index])
          end
        end
      end
    end

    context "when processes user's last attempt" do
      it do
        game.instance_variable_set(:@code, game_code)
        game.instance_variable_set(:@attempts, 1)
        expect(game.guess_code(win_guess)).to eq(described_class::WIN_RESULT)
      end
    end
  end

  context 'with #get_hint' do
    it 'returns digit if hints available' do
      expect(hinted_digit.to_s.size).to eq(1)
      expect(described_class::CODE_RULES[:digits]).to include(hinted_digit)
    end

    it 'returns warning if hints unavailable' do
      game.instance_variable_set(:@hints, 0)
      expect(hinted_digit.to_s).to eq('No hints left!')
    end

    it 'returns digit from the code' do
      expect(game.code).to include(hinted_digit)
    end
  end

  context 'with #statistics' do
    it 'returns current results' do
      game.guess_code(win_guess)
      expect(game.statistics.to_s).to eq({ name: valid_username, difficulty: valid_difficulty.to_s,
                                           attempts_total: game_difficulties[valid_difficulty][:attempts],
                                           attempts_used: 1, hints_total: game_difficulties[valid_difficulty][:hints],
                                           hints_used: 0, date: Date.today }.to_s)
    end
  end

  context 'with game :state' do
    it 'is :new when initialized' do
      game.new_game
      expect(game.state).to eq(:new)
    end

    it 'is :started when #start' do
      expect(game.state).to eq(:started)
    end

    it 'is :win when user guesses the code' do
      game.instance_variable_set(:@code, game_code)
      game.guess_code(win_guess)
      expect(game.state).to eq(:win)
    end

    it 'is :game_over when no more attempts' do
      game.instance_variable_set(:@code, game_code)
      game.instance_variable_set(:@attempts, 0)
      game.guess_code(win_guess)
      expect(game.state).to eq(:game_over)
    end
  end

  context 'when validates username' do
    it 'when valid name' do
      expect(game.username).to eq(valid_username)
    end

    it 'when invalid name' do
      game.new_game
      game.username = invalid_username
      expect(game.username).to be_nil
    end
  end

  context 'when validates difficulty' do
    it 'when valid difficulty' do
      game.class::DIFFICULTIES.keys.each do |difficulty|
        game.new_game
        game.difficulty = difficulty
        expect(game.difficulty).to eq(difficulty)
      end
    end

    it 'when invalid difficulty' do
      game.new_game
      game.difficulty = invalid_difficulty
      expect(game.difficulty).to be_nil
    end
  end
end
