format :html do
  def standard_submit_button
    standard_save_button + standard_save_and_close_button
  end

  def standard_save_button opts={}
    return if voo.hide?(:save_button)
    add_class opts, "submit-button btn-sm mr-3"
    opts[:text] ||= "Save"
    opts["data-cy"] = "save"
    submit_button opts
  end

  # @param close: [:modal, :overlay]
  #
  def standard_save_and_close_button opts={}
    close = opts.delete(:close) || :modal
    add_class opts, "submit-button btn-sm mr-3 _close-#{close}-on-success _update-origin"
    opts.reverse_merge! text: "Save and Close", "data-cy": "submit-#{close}"

    submit_button opts
  end

  def standard_cancel_button args={}
    args.reverse_merge! class: "cancel-button ml-4", href: path, "data-cy": "cancel"
    cancel_button args
  end

  def edit_cancel_button
    modal_close_button "Cancel", situation: "secondary", class: "btn-sm"
  end

  def delete_button opts={}
    link_to "Delete", delete_button_opts(opts)
  end

  def delete_button_opts opts={}
    add_class opts,  "slotter btn btn-outline-danger ml-auto btn-sm"
    opts["data-confirm"] = delete_confirm opts
    opts[:path] = { action: :delete, success: delete_success(opts) }
    opts[:remote] = true
    opts
  end

  def delete_confirm opts
    opts.delete(:confirm) || "Are you sure you want to delete #{safe_name}?"
  end

  def delete_success opts
    opts.delete(:success) || (main? ? "REDIRECT: *previous" : { view: :just_deleted })
  end
end
