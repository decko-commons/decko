describe Card::Set::All::ViewViz do
  # SPECSTUBs
  specify "view views_by_format" do
    expect_view(:views_by_format).to have_tag("div.card") do 
      with_tag "div.card-body"
      with_tag "ul.list-group"
      with_tag "li.list-group-item"
    end
  end
end
