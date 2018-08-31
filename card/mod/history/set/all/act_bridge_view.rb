
format :html do
  def acts_bridge_layout acts, context=:relative
    bs_layout container: true, fluid: true do
       row(12) { act_link_list acts, context }
       row(12) { act_paging acts, context }
    end
  end

  def act_link_list acts, context
    act_list_group acts, context do |act, seq|
      act.card.format(:html).act_link_list_item act, seq, context
    end
  end

  def act_link_list_item act, seq=nil, context=nil
    opts = act_listing_opts_from_params(seq)
    opts[:slot_class] = "revision-#{act.id} history-slot list-group-item"
    context ||= (params[:act_context] || :absolute).to_sym
    act_renderer(context).new(self, act, opts).render
  end

  def act_list_group acts, context, &block
    list_group acts_for_accordion(acts, context, &block), class: "clear-both"
  end
end
