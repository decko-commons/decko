format :html do
  def accordion &block
    wrap_with :div, class: classy("accordion"), &block
  end

  def accordion_item title, **args
    args.reverse_merge!(
      title: title,
      subheader: nil,
      data: nil,
      body: "",
      open: false,
      collapse_id: "card-#{card.name.safe_key}-#{args[:context]}-collapse-id"
    )
    haml :accordion_item, **args
  end
end
