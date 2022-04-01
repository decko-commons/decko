format :html do
  view :navbox, cache: :never do
    select_tag "query[keyword]", "", class: "_navbox navbox form-control w-100",
                                     placeholder: navbar_placeholder
  end

  view :navbar do
    render_core
  end

  view :core do
    form_tag path(mark: :search), method: "get", role: "search",
                                  class: classy("navbox-form", "nodblclick") do
      wrap_with :div, class: "w-100" do
        render_navbox
      end
    end
  end

  # def initial_options
  #   return "" unless (keyword = params.dig :query, :keyword)
  #   options_for_select [keyword]
  # end

  # TODO: the more natural placeholder would be the content of the navbox card, no?
  # Also, the forced division of "raw" and "core" should probably be replaced
  # with a single haml template (for core view)
  def navbar_placeholder
    @placeholder ||= Card[:navbox, "*placeholder"]&.content || "Search"
  end
end
