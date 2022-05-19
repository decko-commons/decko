describe Card::Set::All::ViewViz do
  specify "view views_by_format" do
    expect_view(:views_by_format).to have_tag("div.accordion") do
      with_tag "div.accordion-body" do
        with_tag "ul.list-group" do
          with_tag "li.list-group-item"
        end
      end
    end
  end
end
