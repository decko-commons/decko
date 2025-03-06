basket[:cache_seed_strings] = %w[ASSETS_REFRESHED RULES READRULES ALWAYS]
basket[:cache_seed_names] = [%i[all default]]

def is_template?
  return @is_template unless @is_template.nil?

  @is_template = name.right_name&.codename&.in? %i[structure default]
end

def is_structure?
  return @is_structure unless @is_structure.nil?

  @is_structure = name.right_name&.codename == :structure
end

def template
  # currently applicable templating card.
  # note that a *default template is never returned for an existing card.
  @template ||= begin
    @virtual = false

    if new_card?
      new_card_template
    else
      structure_rule_card
    end
  end
end

def assigns_type?
  # needed because not all *structure templates govern the type of set members
  # for example, X+*type+*structure governs all cards of type X,
  # but the content rule does not (in fact cannot) have the type X.
  pattern_code = Card.quick_fetch(name.trunk_name.tag_name)&.codename
  return false unless pattern_code && (set_class = Set::Pattern.find pattern_code)

  set_class.assigns_type
end

def structure
  template&.is_structure? ? template : nil
end

def structure_rule_card
  return unless (card = rule_card :structure, skip_modules: true)

  card.db_content&.strip == "_self" ? nil : card
end

private

def new_card_template
  default = rule_card :default, skip_modules: true
  return default unless (structure = dup_structure default&.type_id)

  @virtual = true if compound?
  self.type_id = structure.type_id if assign_type_to?(structure)
  structure
end

def dup_structure type_id
  dup_card = dup
  dup_card.type_id = type_id || Card.default_type_id
  dup_card.structure_rule_card
end

def assign_type_to? structure
  type_id == structure.type_id && structure.assigns_type?
end
