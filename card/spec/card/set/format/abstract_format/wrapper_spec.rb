RSpec.describe Card::Set::Format::AbstractFormat::Wrapper do
  describe "simple wrapper" do
    subject do
      format.wrap_with_cream { "cake" }
    end

    let(:format) do
      Card["A"].format_with do
        wrapper :cream do
          "cream_#{interior}_cream"
        end

        wrapper :icon do
          icon_tag interior
        end
      end
    end

    it "is wrapped with cream" do
      expect(subject).to eq "cream_cake_cream"
    end

    it "is possible to use format methods in wrapper" do
      expect(format.wrap_with_icon("edit")).to have_tag :i, "edit"
    end
  end

  describe "html tag wrapper" do
    let(:format) do
      Card["A"].format_with do
        wrapper :cream, :div, class: "creamy"
      end
    end

    context "when called with block" do
      subject do
        format.wrap_with_cream { "cake" }
      end

      it "is wrapped with cream" do
        expect(subject).to have_tag "div.creamy", "cake"
      end
    end

    context "when called with content argument" do
      subject do
        format.wrap_with_cream "cake"
      end

      it "is wrapped with cream" do
        expect(subject).to have_tag "div.creamy", "cake"
      end
    end
  end

  describe "wrapper with options" do
    subject do
      format.wrap_with_cream(topping: "cherry") { "cake" }
    end

    let(:format) do
      Card["A"].format_with do
        wrapper :cream do |opts|
          "#{opts[:topping]}_cream_#{interior}_cream"
        end
      end
    end

    it "is wrapped with cream" do
      expect(subject).to eq "cherry_cream_cake_cream"
    end
  end

  describe "wrapper as view setting" do
    let(:format) do
      Card["A"].format_with do
        wrapper(:cherry, :div, class: "cherry")
        wrapper(:choc, :div, class: "choc")
        wrapper(:cream) { "cream_#{interior}_cream" }

        view(:cream_cake, wrap: :cream) { "cake" }
        view(:cherry_cake, wrap: [:cherry, [:choc, { class: "white" }]]) { "cake" }
        view(:cherry_choc_cake, wrap: { cherry: { class: "sour" },
                                        choc: { class: "white" } }) { "cake" }
      end
    end

    it "wraps with cream" do
      expect(format.render_cream_cake).to eq "cream_cake_cream"
    end

    it "wraps with cherries and white chocolate" do
      expect(format.render_cherry_cake).to have_tag "div.cherry" do
        with_tag "div.choc.white", "cake"
      end
    end

    it "wraps with sour cherries and white chocolate" do
      expect(format.render_cherry_choc_cake).to have_tag "div.cherry.sour" do
        with_tag "div.choc.white", "cake"
      end
    end

    context "with bad options" do
      let(:format) do
        Card["A"].format_with do
          wrapper(:cream) { "cream_#{interior}_cream" }

          view(:unknown_wrapper, wrap: :unknown) { "cake" }
          view(:wrong_arguments, wrap: [:unknown, { opts: :x }]) { "cake" }
        end
      end

      it "raises error for unknown wrapper" do
        expect { format.render_unknown_wrapper }
          .to raise_error(ArgumentError, "unknown wrapper: unknown")
      end

      it "raises error for bad options" do
        expect { format.render_wrong_arguments }
          .to raise_error(ArgumentError, "unknown wrapper: {:opts=>:x}")
      end
    end

    context "with before hook" do
      let(:format) do
        Card["A"].format_with do
          wrapper(:cream) { "#{classy('cream')}_#{interior}_cream" }

          before(:whipped_cream_cake) { class_up "cream", "whipped" }

          view(:whipped_cream_cake, wrap: :cream) { "cake" }
        end
      end

      it "wraps with whipped cream" do
        expect(format.render_whipped_cream_cake).to eq "cream whipped_cake_cream"
      end
    end
  end

  describe "nested wrapper" do
    subject { format.render_kwai }

    let(:format) do
      Card["A"].format_with do
        view :kwai, wrap: :bridge do
          "water"
        end
      end
    end

    it "wrapped with bridge" do
      expect(subject).to have_tag "div#modal-container.modal._modal-slot" do
        with_tag "div.modal-dialog" do
          with_tag "div.modal-content" do
            with_tag "div.modal-body" do
              with_tag "div.bridge", /water/
            end
          end
        end
      end
    end
  end
end
