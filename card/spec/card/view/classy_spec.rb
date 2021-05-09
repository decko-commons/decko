# -*- encoding : utf-8 -*-

RSpec.describe Card::View::Classy do
  it "doesn't change other views on the same level" do
    format =
      Card["A"].format_with do
        view :test do
          [render_a, render_b].join ";"
        end

        view :a do
          class_up "down", "up"
          "a:#{classy 'down'}"
        end
        view(:b) { "b:#{classy 'down'}" }
      end
    expect(format.render_test).to eq "a:down up;b:down"
  end

  it "changes all subviews" do
    format =
      Card["A"].format_with do
        view :test do
          class_up "down", "up"
          [render_a, render_b].join ";"
        end

        view(:a) { "a:#{classy 'down'}" }
        view(:b) { "b:#{classy 'down'}" }
      end
    expect(format.render_test).to eq "a:down up;b:down up"
  end

  it "doesn't change nests" do
    format =
      Card["A"].format_with do
        view :test do
          class_up "card-slot", "up"
          nest("B", view: :closed)
        end
      end
    expect(format.render_test)
      .to have_tag "div.card-slot.SELF-b", without: { class: "up" }
  end

  it "changes only self with self option" do
    format =
      Card["A"].format_with do
        view :test do
          class_up "down", "up", :view
          ["test:#{classy 'down'}", render_a].join ";"
        end

        view(:a) { "a:#{classy 'down'}" }
      end
    expect(format.render_test).to eq "test:down up;a:down"
  end
end
