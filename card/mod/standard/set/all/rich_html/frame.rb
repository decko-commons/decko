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
    with_frame slot do
      wrap_body { yield }
    end
  end

  def with_frame slot=true, header=frame_header, slot_opts={}
    voo.hide :horizontal_menu, :help
    wrap slot, slot_opts do
      panel do
        [header, frame_help, _render(:flash), yield]
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
    [_render_menu, _render_header]
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
end
