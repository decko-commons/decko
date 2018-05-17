format :html do
  view :flash, cache: :never do
    flash_notice = params[:flash] || Env.success.flash
    return "" unless flash_notice.present? && focal?
    Array(flash_notice).join "\n"
  end

  def frame &block
    send frame_method, &block
  end

  def frame_method
    case
    when parent && parent.voo.ok_view == :related
      :related_frame
    else
      :standard_frame
    end
  end

  def standard_frame slot=true
    voo.hide :horizontal_menu, :help
    wrap slot do
      panel do
        [
          frame_header,
          frame_help,
          _render(:flash),
          wrap_body { yield }
        ]
      end
    end
  end

  def related_frame
    voo.show :menu
    class_up "menu-slot", "text-white"
    wrap do
      [
        _render_menu,
        _render_subheader,
        frame_help,
        panel { wrap_body { yield } }
      ]
    end
  end

  def frame_header
    if voo.ok_view == :overlay
      _render_overlay_header
    else
      [_render_menu, _render_header]
    end
  end

  def frame_help
    # TODO: address these args
    with_class_up "help-text", "alert alert-info" do
      _render :help
    end
  end

  def frame_and_form action, form_opts={}
    form_opts ||= {}
    frame do
      card_form action, form_opts do
        output yield
      end
    end
  end

  def panel
    wrap_with :div, class: classy("d0-card-frame") do
      yield
    end
  end

  # alert_types: 'success', 'info', 'warning', 'danger'
  def alert alert_type, dismissable=false, disappear=false, args={}
    classes = ["alert", "alert-#{alert_type}"]
    classes << "alert-dismissible " if dismissable
    classes << "_disappear" if disappear
    args.merge! role: "alert"
    add_class args, classy(classes)
    wrap_with :div, args do
      [(alert_close_button if dismissable), output(yield)]
    end
  end

  def alert_close_button
    wrap_with :button, type: "button", "data-dismiss": "alert",
                       class: "close", "aria-label": "Close" do
      wrap_with :span, "&times;", "aria-hidden" => true
    end
  end
end
