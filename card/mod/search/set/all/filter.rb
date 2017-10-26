format :html do
  def filter_form data
    render_haml :filter_form, categories: data
  end

  def view_template_path view
    super(view, __FILE__)
  end
end

