RSpec.describe Card::Set::Format::Wrapper do
  describe "simple wrapper" do
    let(:format) do
      Card["A"].format_with do
        wrapper :cream do
          wrap_with :div do
            "cream_#{interiour}_cream"
          end
        end
      end
    end

    subject do
      format.wrap_with_cream { "cake" }
    end

    it "is wrapped with cream" do
      is_expected.to eq "cream_cake_cream"
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
        is_expected.to have_tag "div.creamy", "cake"
      end
    end

    context "when called with content argument" do
      subject do
        format.wrap_with_cream "cake"Z
      end

      it "is wrapped with cream" do
        is_expected.to have_tag "div.creamy", "cake"
      end
    end
  end

  describe "wrapper with options" do
    let(:format) do
      Card["A"].format_with do
        wrapper :cream do |opts|
          "#{opts[:topping]}_cream_#{interiour}_cream"
        end
      end
    end

    subject do
      format.wrap_with_cream(topping: "cherry") { "cake" }
    end

    it "is wrapped with cream" do
      is_expected.to eq "cherry_cream_cake_cream"
    end
  end

  describe "wrapper as view setting" do
    let(:format) do
      Card["A"].format_with do
        wrapper :cream do
          "cream_#{interiour}_cream"
        end

        view :cream_cake, wrap: :cream do
          "cake"
        end
      end
    end

    subject { format.render_cream_cake }

    it "is wrapped with cream" do
      is_expected.to eq "cream_cake_cream"
    end
  end
end
