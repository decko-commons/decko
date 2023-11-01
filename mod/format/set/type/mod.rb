format :html do
  view :admin do
    render_core
  end

  view :bar_right do
    %w[settings configurations tasks cardtypes scripts styles].filter do |name|
      card.send("#{name}?")
    end.join ", "
  end

  def before_bar
    voo.show :bar_middle
  end
end
