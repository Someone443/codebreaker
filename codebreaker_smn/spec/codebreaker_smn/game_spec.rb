require 'spec_helper'

RSpec.describe CodebreakerSmn::Game do
  let(:game) { described_class.new }
  let(:game_code) { [1, 2, 3, 4] }
  let(:win_guess) { '1234' }
  let(:invalid_guesses) { ['', 'zz', '123', '11234', '7890', Object] }

  before do
    game.new_game
    game.start
    game.username = 'valid_username'
    game.difficulty = 'easy'
  end

  context 'with #start' do
    it 'generates secret code' do
      expect(game.instance_variable_get(:@code)).not_to be_empty
    end

    it 'saves 4 numbers secret code' do
      expect(game.instance_variable_get(:@code).size).to eq(4)
    end

    it 'saves secret code with numbers from 1 to 6' do
      expect(game.instance_variable_get(:@code).join).to match(/[1-6]+/)
    end
  end

  context 'with #guess_code' do
    context 'when validates user guess' do
      it 'with valid guess' do
        game.instance_variable_set(:@code, game_code)
        expect(game.guess_code(win_guess)).to eq('++++')
      end

      it 'with invalid guess' do
        game.instance_variable_set(:@code, game_code)
        invalid_guesses.each do |invalid_guess|
          expect(game.guess_code(invalid_guess)).to be_nil
        end
      end
    end

    context 'when processes user guesses' do
      let(:examples_1) do
        { code: [6, 5, 4, 3], inputs: %w[5643 6411 6544 3456 6666 2666 2222],
          expected_results: ['++--', '+-', '+++', '----', '+', '-', ''] }
      end
      let(:examples_2) do
        { code: [6, 6, 6, 6], inputs: ['1661'], expected_results: ['++'] }
      end
      let(:examples_3) do
        { code: [1, 2, 3, 4], inputs: %w[3124 1524 1234],
          expected_results: ['+---', '++-', '++++'] }
      end
      let(:examples_4) do
        { code: [1, 4, 5, 5], inputs: ['5133'], expected_results: ['--'] }
      end

      it 'from examples' do
        [examples_1, examples_2, examples_3, examples_4].each do |hash|
          game.start
          game.username = 'valid_username'
          game.difficulty = 'easy'
          game.instance_variable_set(:@code, hash[:code])

          hash[:inputs].each_with_index do |input, index|
            expect(game.guess_code(input)).to eq(hash[:expected_results][index])
          end
        end
      end
    end

    context "when processes user's last attempt" do
      it do
        game.instance_variable_set(:@code, game_code)
        game.send('attempts=', 1)
        expect(game.guess_code(win_guess)).to eq('++++')
      end
    end
  end

  context 'with #get_hint' do
    it 'returns digit if hints available' do
      expect(game.get_hint.to_s).to match(/^[1-6]{1}$/)
    end

    it 'returns warning if hints unavailable' do
      game.send('hints=', 0)
      expect(game.get_hint.to_s).to eq('No hints left!')
    end

    it 'returns digit from the code' do
      expect(game.code).to include(game.get_hint)
    end
  end

  context 'with #high_scores' do
    it 'returns current results' do
      game.guess_code(win_guess)
      expect(game.high_scores.to_s).to eq({ name: 'valid_username', difficulty: 'easy',
                                            attempts_total: 15, attempts_used: 1,
                                            hints_total: 2, hints_used: 0, date: Date.today }.to_s)
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
      game.send('attempts=', 0)
      game.guess_code(win_guess)
      expect(game.state).to eq(:game_over)
    end
  end

  context 'when validates username' do
    it 'when valid name' do
      expect(game.username).to eq('valid_username')
    end

    it 'when invalid name' do
      game.new_game
      game.username = 'zz'
      expect(game.username).to be_nil
    end
  end

  context 'when validates difficulty' do
    it 'when valid difficulty' do
      game.class::DIFFICULTIES.keys.map(&:to_s).each do |difficulty|
        game.new_game
        game.difficulty = difficulty
        expect(game.difficulty).to eq(difficulty)
      end
    end

    it 'when invalid difficulty' do
      game.new_game
      game.difficulty = 'zz'
      expect(game.difficulty).to be_nil
    end
  end
end
