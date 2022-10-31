RSpec.describe Card::Director::CardClass do
  describe "#ensure" do
    def ensure! args={}
      Card.ensure! ensure_args.merge(args)
      ensure_args[lookup_key].card.refresh(true)
    end

    it "raises error with invalid conflict mode" do
      expect { Card.ensure name: "newb", conflict: :bogus }
        .to raise_error Card::Error::ServerError, /invalid conflict mode/
    end

    context "without conflicting name and codename" do
      let(:lookup_key) { :name }

      context "when card is pristine" do
        # C is pristine (and blank)
        let(:ensure_args) { { name: "C", content: "updated" } }

        it "defers when `conflict: :defer`" do
          expect(ensure!(conflict: :defer).content).to eq("")
        end

        it "updates when `conflict: :default`" do
          expect(ensure!(conflict: :default).content).to eq("updated")
        end

        it "updates when `conflict: :override`" do
          expect(ensure!(conflict: :override).content).to eq("updated")
        end
      end

      context "when card is not pristine" do
        # A is not pristine (Joe User has edited it)
        let(:ensure_args) { { name: "A", content: "updated" } }

        it "defers when `conflict: :defer`" do
          expect(ensure!(conflict: :defer).content).to eq("Alpha [[Z]]")
        end

        it "defers when `conflict: :default`" do
          expect(ensure!(conflict: :default).content).to eq("Alpha [[Z]]")
        end

        it "updates when `conflict: :override`" do
          expect(ensure!(conflict: :override).content).to eq("updated")
        end
      end
    end

    context "with codename and name" do
      after { Card::Codename.reset_cache }
      let(:lookup_key) { :codename }

      context "with known codename" do
        let(:ensure_args) { { name: "A", codename: :admin, content: "updated" } }

        it "defers when `conflict: :defer`" do
          expect(ensure!(conflict: :defer).name).to eq("*admin")
        end

        it "defers when `conflict: :default`", as_bot: true do
          expect(ensure!(conflict: :default).name).to eq("*admin")
        end

        it "updates when `conflict: :override`", as_bot: true do
          expect(ensure!(conflict: :override).name).to eq("A")
        end
      end

      context "with unknown codename and known name" do
        let(:ensure_args) { { name: "A", codename: :stranger, content: "updated" } }

        it "alters name`conflict: :defer`" do
          expect(ensure!(conflict: :defer).name).to eq("A 1")
        end

        it "defers when `conflict: :default`", as_bot: true do
          expect(ensure!(conflict: :default).name).to eq("A 1")
        end

        it "updates when `conflict: :override`", as_bot: true do
          expect(ensure!(conflict: :override).name).to eq("A")
        end
      end
    end
  end
end
