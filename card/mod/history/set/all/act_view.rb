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
  def acts_layout acts, context, per_page, draft_legend=:hide
    bs_layout container: true, fluid: true do
      html _render_act_legend(draft_legend => :draft_legend)
      row(12) { act_list acts, context, per_page }
      row(12) { act_paging acts, per_page }
    end
  end

  def act_list acts, context, per_page
    act_accordion acts, per_page do |act, seq|
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

  def act_accordion acts, per_page
    accordion_group nil, class: "clear-both" do
      seq = act_list_starting_seq(acts, per_page) + 1
      clean_acts(current_page_acts(acts, per_page)).map do |act|
        seq -= 1
        yield act, seq
      end
    end
  end

  def clean_acts acts
    # FIXME: if we get rid of bad act data, this will not be necessary
    # (in the meantime, it will make paging confusing)
    acts.reject { |a| !a.card }
  end

  def current_page_acts acts, per_page
    acts.page(acts_page_from_params).per(per_page)
  end

  def act_list_starting_seq acts, per_page
    acts.size - (acts_page_from_params - 1) * per_page
  end

  def acts_page_from_params
    @act_page_from_params ||= params["page"].present? ? params["page"].to_i : 1
  end

  def act_paging acts, per_page
    wrap_with :span, class: "slotter" do
      acts = current_page_acts acts, per_page
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
