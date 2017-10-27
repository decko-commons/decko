# encoding: utf-8
require_relative "../../spec_helper"

RSpec.describe Cardname::Parts do
  describe 'simple?' do
    it 'returns true for empty name' do
      expect("".to_name.simple?).to eq true
    end
    it 'returns true for simple name' do
      expect("a name".to_name.simple?).to eq true
    end
    it 'returns false for junction name' do
      expect("A+B".to_name.simple?).to eq false
    end
    it 'returns false for junction with empty part' do
      expect("A+".to_name.simple?).to eq false
    end
  end

  describe 'parts and pieces' do
    it 'produces simple strings for parts' do
      expect('A+B+C+D'.to_name.parts).to eq(%w( A B C D ))
    end

    it 'produces simple name objects for part_names' do
      expect('A+B+C+D'.to_name.part_names).to eq(%w( A B C D ).map(&:to_name))
    end

    it 'produces compound strings for pieces' do
      expect('A+B+C+D'.to_name.pieces).to eq(%w( A B C D A+B A+B+C A+B+C+D ))
    end

    it 'produces compound name objects for piece_names' do
      expect('A+B+C+D'.to_name.piece_names).to eq(
        %w( A B C D A+B A+B+C A+B+C+D ).map(&:to_name)
      )
    end
  end

  describe '#left_name' do
    it 'returns nil for non junction' do
      expect('a'.to_name.left_name).to eq(nil)
    end

    it 'returns parent for parent' do
      expect('a+b+c+d'.to_name.left_name).to eq('a+b+c')
    end
  end

  describe '#tag_name' do
    it 'returns last part of plus card' do
      expect('a+b+c'.to_name.tag).to eq('c')
    end

    it 'returns name of simple card' do
      expect('a'.to_name.tag).to eq('a')
    end
  end

  describe 'array methods' do
    it 'flatten preserves empty names' do
      expect(["".to_name, "A"].flatten.to_name.s).to eq "+A"
    end

    it 'flatten preserves names' do
      expect([["A+B".to_name], "C+D".to_name].flatten).to eq ["A+B".to_name, "C+D".to_name]
    end
  end
end
