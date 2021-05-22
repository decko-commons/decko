describe Bootstrap::Component::Layout, "layout dsl" do
  let(:format) { Card["A"].format(:html) }

  it "creates correct layout with column array" do
    layout = format.bs_layout container: true, fluid: true do
      row 6, 4, 2, class: "six-times-six" do
        %w[c1 c2 c3]
      end
    end
    expect(layout).to have_tag("div.container-fluid") do
      with_tag "div.row.six-times-six" do
        with_tag "div.col-md-6", text: /c1/
        with_tag "div.col-md-4", text: /c2/
        with_tag "div.col-md-2", text: /c3/
      end
    end
  end

  it "creates correct layout with column calls" do
    layout = format.bs_layout do
      row 8, 4, class: "six-times-six" do
        column "c1"
        column "c2", class: "extra-class"
      end
    end
    expect(layout).to have_tag("div.row.six-times-six") do
      with_tag "div.col-md-8", text: /c1/
      with_tag "div.col-md-4.extra-class", text: /c2/
    end
  end

  it "handles different medium sizes" do
    layout = format.bs_layout do
      row md: [8, 4], xs: [6, 6], class: "six-times-six" do
        column "c1"
        column "c2", class: "extra-class"
      end
    end
    expect(layout).to have_tag("div.row.six-times-six") do
      with_tag "div.col-md-8.col-6", text: /c1/
      with_tag "div.col-md-4.col-6.extra-class", text: /c2/
    end
  end

  it "works without column" do
    layout = format.bs_layout do
      row do
        "test"
      end
    end
    expect(layout).to have_tag "div.row", text: /test/
  end

  it "handles layout sequence" do
    # format = Card["A"].form
    lay = format.bs do
      layout do
        row 8, 4 do
          column "c1"
          column "c2"
        end
      end

      layout do
        row 12, class: "six-times-six" do
          column "new column"
        end
      end
    end

    expect(lay).to have_tag "div.row.six-times-six" do
      with_tag "div.col-md-12", text: /new column/
    end
  end

  it "handles nested layouts" do
    # format = Card["A"].format :html
    lay = format.bs do
      layout do
        row 8, 4 do
          column do
            layout { row 12, ["c1"] }
          end
          column do
            row 12, ["c2"]
            row 6 do
              html "<span>s1</span>"
              column "c3"
            end
            row 8 do
              "some content"
            end
          end
        end
      end
    end

    expect(lay).to have_tag("div.row") do
      with_tag "div.col-md-8" do
        with_tag "div.row" do
          with_tag "div.col-md-12", text: /c1/
        end
      end
      with_tag "div.col-md-4" do
        with_tag "div.row" do
          with_tag "div.col-md-12", text: /c2/
        end
        with_tag "div.row" do
          with_tag "div.col-md-6", text: /c3/
          with_tag "span", text: /s1/
        end
        with_tag "div.row", text: /some content/
      end
    end
  end
end
