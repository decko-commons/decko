# -*- encoding : utf-8 -*-

describe CoreExtensions do
  context Hash do
    describe "#new_nested" do
      it "creates nested hashes" do
        nested_hash = Hash.new_nested Hash, Hash
        expect(nested_hash[:a]).to be_instance_of Hash
        expect(nested_hash[:a][:b]).to be_instance_of Hash
        expect(nested_hash[:d][:c]).to be_instance_of Hash
      end

      it "creates set in hash" do
        nested_hash = Hash.new_nested ::Set
        expect(nested_hash[:a]).to be_instance_of ::Set
      end
    end

    describe "#bury" do
      it "works with a blank hash" do
        expect({}.bury(:a, :b, 1)).to eq(a: { b: 1 })
      end

      it "doesn't override existing hashes" do
        expect({ d: :e }.bury(:a, :b, 4)).to eq({ a: { b: 4 }, d: :e })
      end

      it "overrides existing values" do
        expect({ a: { b: 5 }}.bury(:a, :b, 6)).to eq(a: { b: 6 })
      end
    end
  end

  context CoreExtensions::PersistentIdentifier do
    describe "#name" do
      subject { :wagn_bot.cardname }
      it "converts into a name" do
        is_expected.to be_instance_of Card::Name
        expect(subject.s).to eq "Decko Bot"
      end
    end

    describe "#card" do
      context "called on Integer" do
        subject { Card::LogoID.card }
        it "converts into a card" do
          is_expected.to be_instance_of Card
          expect(subject.id).to eq Card::LogoID
        end
      end

      context "called on Symbol" do
        subject { :logo.card }
        it "converts into a card" do
          is_expected.to be_instance_of Card
          expect(subject.key).to eq(:logo.cardname.key)
        end
      end
    end
  end
end
