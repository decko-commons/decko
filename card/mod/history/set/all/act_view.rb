ACTS_PER_PAGE = Card.config.acts_per_page

format :html do
  view :act, cache: :never do
    act_listing act_from_context
  end

  def act_from_context
    if (act_id = params["act_id"])
      Act.find(act_id) || raise(Card::NotFound, "act not found")
    else
      card.last_action.act
    end
  end

  view :act_legend do
    bs_layout do
      row md: [12, 12], lg: [7, 5] do
        col action_legend
        col content_legend, class: "text-right"
      end
    end
  end

  # used (by history and recent)for rendering act lists with legend and paging
  #
  # @param acts [ActiveRecord::Relation] relation that will return acts objects
  # @param context [Symbol] :relative or :absolute
  # @param draft_legend [Symbol] :show or :hide
  def acts_layout acts, context, draft_legend=:hide
    bs_layout container: true, fluid: true do
      html _render_act_legend(draft_legend => :draft_legend)
      row(12) { act_list acts, context }
      row(12) { act_paging acts }
    end
  end

  def act_list acts, context
    act_accordion acts do |act, seq|
      act.card.format(:html).act_listing act, seq, context
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

  def act_accordion acts, &block
    accordion_group acts_for_accordion(acts, &block), nil, class: "clear-both"
  end

  def acts_for_accordion acts
    seq = act_list_starting_seq(acts) + 1
    clean_acts(current_page_acts(acts)).map do |act|
      seq -= 1
      yield act, seq
    end
  end

  def clean_acts acts
    # FIXME: if we get rid of bad act data, this will not be necessary
    # The current
    acts.reject { |a| !a.card }
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
    @act_page_from_params ||= params["page"].present? ? params["page"].to_i : 1
  end

  def act_paging acts
    wrap_with :span, class: "slotter" do
      acts = current_page_acts acts
      paginate acts, remote: true, theme: "twitter-bootstrap-4"
    end
  end

  def action_icon action_type, extra_class=nil
    icon = case action_type
           when :create then :plus
           when :update then :pencil
           when :delete then :trash
           when :draft then :wrench
           end
    icon_tag icon, extra_class
  end

  private

  def act_renderer context
    if context == :absolute
      Act::ActRenderer::AbsoluteActRenderer
    else
      Act::ActRenderer::RelativeActRenderer
    end
  end
end
