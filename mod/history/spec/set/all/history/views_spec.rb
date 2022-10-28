# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::History::Views do
  check_views_for_errors

  specify "view act" do
    expect_view(:act).to have_tag("div.accordion-item") do
      with_tag "h2.accordion-header"
      with_tag "div.accordion-collapse" do
        with_tag "div.accordion-body"
      end
    end
  end

  specify "view act_legend" do
    expect_view(:act_legend).to have_tag("div.row") do
      with_tag "div"
    end
  end

  specify "view action_summary" do
    expect_view(:action_summary).to have_tag("div.card-slot") do
      with_tag "ins"
    end
  end

  specify "view history" do
    expect_view(:history).to have_tag("div.card-slot.history-view") do
      with_tag "div.card-body"
      with_tag "div.card-header"
    end
  end
end
