include_set Abstract::Lock

def followable?
  false
end

def history?
  false
end

def clean_html?
  false
end

def write! new_content
  lock do
    if new_card?
      update_attributes! content: new_content
    elsif new_content != solid_cache_card.content
      update_column :db_content, new_content
      expire
    end
  end
end

format :html do
  view :core, cache: :never do
    return super() unless card.new_card?
    @denied_view = :core
    _render_missing
  end

  view :missing, cache: :never do
    if @card.new_card? && (l = @card.left) && l.solid_cache?
      l.update_solid_cache
      @card = Card.fetch card.name
      render! @denied_view
    else
      super()
    end
  end

  view :new, :missing
end
