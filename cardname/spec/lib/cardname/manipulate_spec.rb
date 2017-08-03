# encoding: utf-8
require_relative "../../spec_helper"

RSpec.describe Cardname::Manipulate do
  describe '#replace' do
    def replace str, change
      str.to_name.replace(*change.to_a.flatten).to_s
    end

    it 'replaces first name part' do
      expect(replace 'a+b', 'a' => 'x').to eq('x+b')
    end
    it 'replaces last name part' do
      expect(replace 'a+b', 'b' => 'x').to eq('a+x')
    end
    it 'replaces middle name part' do
      expect(replace 'a+c+b', 'c' => 'x').to eq('a+x+b')
    end
    it 'replaces all occurences' do
      expect(replace'a+c+b+c+c','c' => 'x').to eq('a+x+b+x+x')
    end
    it 'replaces junction' do
      expect(replace'a+b+c', 'a+b' => 'x').to eq('x+c')
      expect(replace'a+b+c+d', 'a+b' => 'e+f').to eq('e+f+c+d')
    end
    it "replaces two part tag" do
      expect(replace'a+b+c','b+c' => 'x').to eq('a+x')
    end
    it "replaces whole name" do
      expect(replace'a+b+c','a+b+c' => 'x').to eq('x')
    end

    it "replaces based on key match" do
      expect(replace'A+ b +C?','a+b+c' => 'x').to eq('x')
    end
    it "replaces with original format" do
      expect(replace'a+b','a+B' => 'X?+C').to eq('X?+C')
    end
  end

  describe '#replace_part' do
    def replace str, change
      str.to_name.replace_part(*change.to_a.flatten).to_s
    end
    it 'replaces all occurences' do
      expect(replace'a+c+b+c+c','c' => 'x').to eq('a+x+b+x+x')
    end
    context "first argument is not a part" do
      it 'raises error' do
        expect { replace('a+c+b','a+c' => 'x') }.to raise_error(StandardError, /has to be simple/)
      end
    end
  end

  describe '#replace_piece' do
    def replace str, change
      str.to_name.replace_piece(*change.to_a.flatten).to_s
    end
    it "replaces two part trunk" do
      expect(replace('a+b+c', 'a+b' =>'x')).to eq('x+c')
    end
    it "doesn't replace two part tag" do
      expect(replace('a+b+c', 'b+c' => 'x')).to eq('a+b+c')
    end
    it "replaces whole name" do
      expect(replace'a+b+c','a+b+c' => 'x').to eq('x')
    end
    it "replaces based on key match" do
      expect(replace'A+ b +C?','a+b+c' => 'x').to eq('x')
    end
    it "replaces with original format" do
      expect(replace'a+b','a+B' => 'X?+C').to eq('X?+C')
    end
  end
end
