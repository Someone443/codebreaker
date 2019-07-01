require 'spec_helper'

RSpec.describe CodebreakerSmn::Game do
  let(:game) { CodebreakerSmn::Game.new }
  let(:game_code) { [1, 2, 3, 4] }
  let(:valid_guess) { '1234' }
  let(:invalid_guess) { '1111' }

  context '#start' do
    it 'generates secret code' do
      game.start
      expect(game.instance_variable_get(:@code)).not_to be_empty
    end

    it 'saves 4 numbers secret code' do
      game.start
      expect(game.instance_variable_get(:@code).size).to eq(4)
    end

    it 'saves secret code with numbers from 1 to 6' do
      game.start
      expect(game.instance_variable_get(:@code).join).to match(/[1-6]+/)
    end
  end

  context '#guess_code' do
    #it 'validates user guess' do
      #skip
      # validate that code is 4 digits long and accepts only digits
      # validate digits from 1 to 6
    #end
    
    context 'processes user guesses' do
      let(:examples_1) { {code: [6, 5, 4, 3], 
                        inputs: ['5643', '6411', '6544', '3456', '6666', '2666', '2222'],
                        expected_results: ['++--', '+-', '+++', '----', '+', '-', '']} }
      let(:examples_2) { {code: [6, 6, 6, 6], 
                        inputs: ['1661'],
                        expected_results: ['++']} }
      let(:examples_3) { {code: [1, 2, 3, 4], 
                        inputs: ['3124', '1524', '1234'],
                        expected_results: ['+---', '++-', '++++']} }

      before(:each) do
        game.start
        game.set_difficulty('easy')
      end

      it 'from examples_1' do
        game.instance_variable_set(:@code, examples_1[:code])

        examples_1[:inputs].each_with_index do |input, index|
          expect(game.guess_code(input)).to eq(examples_1[:expected_results][index])
        end
      end

      it 'from examples_2' do
        game.instance_variable_set(:@code, examples_2[:code])

        examples_2[:inputs].each_with_index do |input, index|
          expect(game.guess_code(input)).to eq(examples_2[:expected_results][index])
        end
      end

      it 'from examples_3' do
        game.instance_variable_set(:@code, examples_3[:code])

        examples_3[:inputs].each_with_index do |input, index|
          expect(game.guess_code(input)).to eq(examples_3[:expected_results][index])
        end
      end
    end

    context "processes user's last attempt" do
      it do
        game.start
        game.set_difficulty('easy')
        game.instance_variable_set(:@code, game_code)
        game.send('attempts=', 1)
        expect(game.guess_code(valid_guess)).to eq('++++')
      end
    end

    context "when no more attempts" do
      it do
        game.start
        game.set_difficulty('easy')
        game.instance_variable_set(:@code, game_code)
        game.send('attempts=', 0)
        game.guess_code(valid_guess)
        expect(game.state).to eq(:game_over) 
      end
    end
  end

  context '#get_hint' do
    before(:each) do
      game.start
      game.set_difficulty('easy')
      game.instance_variable_set(:@code, game_code)
    end

    it 'returns digit if hints available' do
      expect(game.get_hint.to_s).to match(/^[1-6]{1}$/)
    end

    it 'returns warning if hints unavailable' do
      game.send('hints=', 0)
      expect(game.get_hint.to_s).to eq('No hints left!')
    end    
  end

  context '#high_scores' do
    it 'returns results' do
      expect { game.high_scores }.to output(/Name, Difficulty, Attempts Total, Attempts Used, Hints Total, Hints Used/).to_stdout
    end  
  end  

  context '#save_results' do
    it 'saves results' do
      game.start
      game.set_difficulty('easy')
      game.instance_variable_set(:@code, game_code)
      expect(game.guess_code(valid_guess)).to eq('++++')

      allow(File).to receive(:write).with('./db/results.yml', /.*/)

      game.save_results
    end  
  end

  context 'validate username' do
    it 'with valid name' do
      expect(game.valid_name?('valid_username')).to eq(true)
    end

    it 'with invalid name' do
      expect(game.valid_name?('zz')).to eq(false)
    end
  end
end