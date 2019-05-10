
def is_template?
  return @is_template unless @is_template.nil?

  @is_template = name.trait_name? :structure, :default
end

def is_structure?
  return @is_structure unless @is_structure.nil?

  @is_structure = name.trait_name? :structure
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

def default_type_id default_card=nil
  default_card ? default_card.type_id : Card.default_type_id
end

def new_card_template
  default = rule_card :default, skip_modules: true

  dup_card = dup
  dup_card.type_id = default_type_id default

  if (structure = dup_card.structure_rule_card)
    @virtual = true if junction?
    self.type_id = structure.type_id if assign_type_to?(structure)
    structure
  else
    default
  end
end

def assign_type_to? structure
  return if type_id == structure.type_id
  structure.assigns_type?
end

def assigns_type?
  # needed because not all *structure templates govern the type of set members
  # for example, X+*type+*structure governs all cards of type X,
  # but the content rule does not (in fact cannot) have the type X.
  pattern_code = Card.quick_fetch(name.trunk_name.tag_name)&.codename
  return unless pattern_code && (set_class = Set::Pattern.find pattern_code)

  set_class.assigns_type
end

def structure
  return unless template && template.is_structure?
  template
end

def structure_rule_card
  return unless (card = rule_card :structure, skip_modules: true)

  card.db_content&.strip == "_self" ? nil : card
end
