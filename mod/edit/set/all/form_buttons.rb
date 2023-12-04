format :html do
  def standard_submit_button
    output [standard_save_button, standard_save_and_close_button]
  end

  # Generates a standard save button with optional customization.
  # @param opts (dict, optional): A dictionary containing customization options
  #   - If voo is not nil and does not hide the save button, a save button is generated
  #   - If present, "text" key in opts sets the text content of the button (default is "Save")
  #   - "data-cy" attribute is set to "save" for end-to-end testing purposes
  #   - CSS class "submit-button me-3 _update-history-pills" is applied
  # Returns:
  #   - None: If the save button is not generated due to the hide condition.
  # Example:
  #   standard_save_button({"text": "Submit", "data-cy": "submit_button"})
  #   This example generates a customized save button with the text "Submit"
  #   and a "data-cy" attribute for testing.
  def standard_save_button opts={}
    return if voo&.hide?(:save_button)

    add_class opts, "submit-button me-3 _update-history-pills"
    opts[:text] ||= "Save"
    opts["data-cy"] = "save"
    submit_button opts
  end

  # @param opts [Hash]
  # @option close [:modal, :overlay]
  #
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
