FIELD_HELPERS =
  %w[
    hidden_field color_field date_field datetime_field datetime_local_field
    email_field month_field number_field password_field phone_field
    range_field search_field telephone_field text_area text_field time_field
    url_field week_field file_field label check_box radio_button
  ].freeze

format :html do
  FIELD_HELPERS.each do |method_name|
    define_method(method_name) do |*args|
      form.send(method_name, *args)
    end
  end

  def success_tags opts
    return "" unless opts.present?

    hidden_tags success: opts
  end

  # convert hash into a collection of hidden tags
  def hidden_tags hash, base=nil, options={}
    hash ||= {}
    hash.inject("") do |result, (key, val)|
      new_base = base ? "#{base}[#{key}]" : key
      result + process_hidden_value(val, new_base, options)
    end
  end

  def process_hidden_value val, base, options={}
    case val
    when Hash
      hidden_tags val, base, options
    when Array
      base += "[]"
      val.map do |v|
        process_hidden_value v, base, options
      end.join
    else
      hidden_field_tag base, val, options
    end
  end

  # Generates an HTML submit button with optional parameters.
  #
  # @param [Hash] args The options for the submit button.
  # @option args [String] :text ("Submit") The text displayed on the button.
  # @option args [String] :situation ("primary") The visual style of the button.
  #   Possible values: "primary", "secondary", "success", "danger", etc.
  # @option args [Hash] :data ({}) Additional data attributes for the button.
  # @option args [String] :disable_with ("Submitting") Text to display on the button
  #   while it is being submitted/disabled.
  #
  # @return [String] The HTML code for the submit button.
  #
  # @example
  #   submit_button(text: "Create", situation: "success", disable_with: "Creating")
  def submit_button args={}
    text = args.delete(:text) || "Submit"
    args.reverse_merge! situation: "primary", data: {}
    args[:data][:disable_with] ||= args.delete(:disable_with) || "Submitting"
    button_tag text, args
  end

  # redirect to *previous if no :href is given
  def cancel_button args={}
    return unless voo.show? :cancel_button

    text = args.delete(:text) || "Cancel"
    add_class args, "btn btn-#{args.delete(:situation) || 'secondary'}"
    add_class args, cancel_strategy(args[:redirect], args[:href])
    args[:href] ||= path_to_previous
    args["data-remote"] = true
    link_to text, args
  end

  def cancel_strategy redirect, href
    redirect = href.blank? if redirect.nil?
    redirect ? "redirecter" : "slotter"
  end

  def path_to_previous
    path mark: "*previous"
  end
end
