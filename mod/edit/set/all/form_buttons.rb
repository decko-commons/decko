format :html do
  def standard_submit_button
    output [standard_save_button, standard_save_and_close_button]
  end

# Generates a standard save button with optional parameters.
#
# @param [Hash] opts The options for the save button.
# @option opts [String] :text ("Save") The text displayed on the button.
# @option opts [String] :data-cy ("save") The value for the 'data-cy' attribute
#   used for testing or identification purposes.
#
# @return [String] The HTML code for the standard save button.
#
# @example
#   standard_save_button(text: "Update")
#   #=> "<button class='submit-button me-3 _update-history-pills' data-cy='save'\
#        data-disable-with='Submitting'>Update</button>"
# 
  def standard_save_button opts={}
    return if voo&.hide?(:save_button)

    add_class opts, "submit-button me-3 _update-history-pills"
    opts[:text] ||= "Save"
    opts["data-cy"] = "save"
    submit_button opts
  end

  # @param opts [Hash]
  # @option close [:modal, :overlay]
  def standard_save_and_close_button opts={}
    close = opts.delete(:close) || :modal
    text = opts[:text] || "Save and Close"
    add_class opts, "submit-button me-3 _close-on-success"
    add_class opts, "_update-origin" unless opts[:no_origin_update]
    opts.reverse_merge! text: text, "data-cy": "submit-#{close}"

    submit_button opts
  end

  def standard_cancel_button args={}
    args.reverse_merge! class: "cancel-button ms-4", href: path, "data-cy": "cancel"
    cancel_button args
  end

  def modal_cancel_button
    modal_close_button "Cancel", situation: "secondary", class: "cancel-button"
  end

  def edit_cancel_button
    modal_cancel_button
  end

  def new_cancel_button
    voo.show?(:cancel_button) && modal_cancel_button
  end

  def delete_button opts={}
    return unless card.real?

    link_to "Delete", delete_button_opts(opts)
  end

  def delete_button_opts opts={}
    add_class opts,  "slotter btn btn-outline-danger ms-auto"
    opts["data-confirm"] = delete_confirm opts
    opts[:path] = { action: :delete }
    opts[:path][:success] = delete_success(opts)
    opts[:remote] = true
    opts
  end

  def delete_confirm opts
    opts.delete(:confirm) || "Are you sure you want to delete #{safe_name}?"
  end

  def delete_success opts
    if opts[:success]
      opts.delete :success
    elsif main?
      { redirect: true, mark: "*previous" }
    else
      { view: :just_deleted }
    end
  end
end
