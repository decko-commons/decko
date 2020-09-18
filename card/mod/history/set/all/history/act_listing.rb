ACTS_PER_PAGE = Card.config.acts_per_page

format :html do
  def act_from_context
    if (act_id = params["act_id"])
      Act.find(act_id) || raise(Card::NotFound, "act not found")
    else
      card.last_action.act
    end
  end

  # used (by history and recent)for rendering act lists with legend and paging
  #
  # @param acts [ActiveRecord::Relation] relation that will return acts objects
  # ARDEP: Relation
  # @param context [Symbol] :relative or :absolute
  # @param draft_legend [Symbol] :show or :hide
  def acts_layout acts, context, draft_legend=:hide
    bs_layout container: false, fluid: false do
      html _render_act_legend(draft_legend => :draft_legend)
      row(12) { act_list acts, context }
      row(12) { act_paging acts, context }
    end
  end

  def act_list acts, context
    act_accordion acts, context do |act, seq|
      fmt = context == :relative ? self : act.card.format(:html)
      fmt.act_listing act, seq, context
    end
  end

  def act_listing act, seq=nil, context=nil
    opts = act_listing_opts_from_params(seq)
    opts[:slot_class] = "revision-#{act.id} history-slot list-group-item"
    context ||= (params[:act_context] || :absolute).to_sym
    act_renderer(context).new(self, act, opts).render
  end

  # TODO: consider putting all these under one top-level param, eg:
  # act: { seq: X, diff: [show/hide], action_view: Y }
  def act_listing_opts_from_params seq
    { act_seq: (seq || params["act_seq"]),
      action_view: (params["action_view"] || "summary").to_sym,
      hide_diff: params["hide_diff"].to_s.strip == "true" }
  end

  def act_accordion acts, context, &block
    accordion_group acts_for_accordion(acts, context, &block), nil, class: "clear-both"
  end

  def acts_for_accordion acts, context
    clean_acts(current_page_acts(acts)).map do |act|
      with_act_seq(context, acts) do |seq|
        yield act, seq
      end
    end
  end

  def with_act_seq context, acts
    yield(context == :absolute ? nil : current_act_seq(acts))
  end

  def current_act_seq acts
    @act_seq = @act_seq ? (@act_seq -= 1) : act_list_starting_seq(acts)
  end

  def clean_acts acts
    # FIXME: if we get rid of bad act data, this will not be necessary
    # The current
    acts.select(&:card)
  end

  def current_page_acts acts
    acts.page(acts_page_from_params).per acts_per_page
  end

  def act_list_starting_seq acts
    acts.size - (acts_page_from_params - 1) * acts_per_page
  end

  def acts_per_page
    @acts_per_page || ACTS_PER_PAGE
  end

  def acts_page_from_params
    @acts_page_from_params ||= params["page"].present? ? params["page"].to_i : 1
  end

  def act_paging acts, context
    wrap_with :div, class: "slotter btn-sm" do
      acts = current_page_acts acts
      opts = { remote: true, theme: "twitter-bootstrap-4" }
      opts[:total_pages] = 10 if limited_paging? context
      paginate acts, opts
    end
  end

  def limited_paging? context
    context == :absolute && Act.count > 1000
  end

  def action_icon action_type, extra_class=nil
    icon = case action_type
           when :create then :add_circle
           when :update then :pencil
           when :delete then :remove_circle
           when :draft then :wrench
           end
    icon_tag icon, extra_class
  end

  private

  def act_renderer context
    case context
    when :absolute
      Act::ActRenderer::AbsoluteActRenderer
    when :bridge
      Act::ActRenderer::BridgeActRenderer
    else # relative
      Act::ActRenderer::RelativeActRenderer
    end
  end
end
