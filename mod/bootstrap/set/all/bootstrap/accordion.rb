format :html do


  def accordion &block
    wrap_with :div, class: "accordion", &block
  end

  def accordion_item title, **args
    args.reverse_merge!(
      title: title,
      body: "",
      open: false,
      collapse_id: "#{card.name.safe_key}-#{title.to_name.safe_key}-collapse-id"
    )
    haml :accordion_item, **args
  end
end
