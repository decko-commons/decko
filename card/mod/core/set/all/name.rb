require "uuid"

module ClassMethods
  def uniquify_name name, rename=:new
    return name unless Card.exists? name
    uniq_name = generate_alternative_name name
    return uniq_name unless rename == :old
    rename!(name, uniq_name)
    name
  end

  def generate_alternative_name name
    uniq_name = "#{name} 1"
    uniq_name.next! while Card.exists?(uniq_name)
    uniq_name
  end

  def rename! oldname, newname
    Card[oldname].update! name: newname, update_referers: true
  end
end

def name
  @name ||= left_id ? Card::Lexicon.lex_to_name([left_id, right_id]) : super.to_name
end

def key
  @key ||= left_id ? name.key : super
end

def name= newname
  @name = superize_name newname.to_name
  self.key = @name.key
  update_subcard_names @name
  write_attribute :name, (@name.simple? ? @name.s : nil)
  assign_side_ids
  @name
end

def assign_side_ids
  if name.simple?
    self.left_id = self.right_id = nil
  else
    assign_side_id :left_id=, :left_name
    assign_side_id :right_id=, :right_name
  end
end

# assigns left_id and right_id based on names.
# if side card is new, id is temporarily stored as -1
def assign_side_id side_id_equals, side_name
  side_id = Card::Lexicon.id(name.send(side_name)) || -1
  send side_id_equals, side_id
end

def superize_name cardname
  return cardname unless @supercard
  @raw_name = cardname.s
  @supercard.subcards.rename key, cardname.key
  update_superleft cardname
  cardname.absolute_name @supercard.name
end

def update_superleft cardname
  @superleft = @supercard if cardname.field_of? @supercard.name
end

def key= newkey
  return if newkey == key
  update_cache_key key do
    write_attribute :key, (name.simple? ? newkey : nil)
    @key = newkey
  end
  clean_patterns
  @key
end

def clean_patterns
  return unless patterns?
  reset_patterns
  patterns
end

def update_cache_key oldkey
  yield
  was_in_cache = Card.cache.soft.delete oldkey
  Card.write_to_soft_cache self if was_in_cache
end

def update_subcard_names new_name, name_to_replace=nil
  return unless @subcards
  subcards.each do |subcard|
    update_subcard_name subcard, new_name, name_to_replace if subcard.new?
  end
end

def update_subcard_name subcard, new_name, name_to_replace
  name_to_replace ||= name_to_replace_for_subcard subcard, new_name
  subcard.name = subcard.name.swap name_to_replace, new_name.s
  subcard.update_subcard_names new_name, name # needed?  shouldn't #name= trigger this?
end

def name_to_replace_for_subcard subcard, new_name
  # if subcard has a relative name like +C
  # and self is a subcard as well that changed from +B to A+B then
  # +C should change to A+B+C. #replace doesn't work in this case
  # because the old name +B is not a part of +C
  if subcard.name.starts_with_joint? && new_name.parts.first.present?
    "".to_name
  else
    name
  end
end

def autoname name
  if Card.exists?(name) || Director.include?(name)
    autoname name.next
  else
    name
  end
end

# FIXME: use delegations and include all name functions
def simple?
  name.simple?
end

def junction?
  name.junction?
end

def raw_name
  @raw_name || name
end

def left *args
  case
  when simple?    then nil
  when superleft then superleft
  when name_is_changing? && name.to_name.trunk_name == name_before_act.to_name
    nil # prevent recursion when, eg, renaming A+B to A+B+C
  else
    Card.fetch name.left, *args
  end
end

def right *args
  Card.fetch(name.right, *args) unless simple?
end

def [] *args
  case args[0]
  when Integer, Range
    fetch_name = Array.wrap(name.parts[args[0]]).compact.join Card::Name.joint
    Card.fetch(fetch_name, args[1] || {}) unless simple?
  else
    super
  end
end

def trunk *args
  simple? ? self : left(*args)
end

def tag *args
  simple? ? self : Card.fetch(name.right, *args)
end

def left_or_new args={}
  left(args) || Card.new(args.merge(name: name.left))
end

# NOTE: for all these helpers, method returns *all* fields/children/descendants.
# (Not just those current user has permission to read.)

def fields
  field_ids.map { |id| Card[id] }
end

def field_names
  field_ids.map { |id| Card::Name[id] }
end

def field_ids
  child_ids :left
end

def each_child
  child_ids.each do |id|
    (child = Card[id]) && yield(child)
    # check should not be needed (remove after fixing data problems)
  end
end

# eg, A+B is a child of A and B
def child_ids side=nil
  return [] unless id
  side ||= name.simple? ? :part : :left_id
  Auth.as_bot do
    Card.search({ side => id, return: :id, limit: 0 }, "children of #{name}")
  end
end

def each_descendant &block
  each_child do |child|
    yield child
    child.each_descendant(&block)
  end
end

def right_id= cardish
  write_card_or_id :right_id, cardish
end

def left_id= cardish
  write_card_or_id :left_id, cardish
end

def write_card_or_id attribute, cardish
  when_id_exists(cardish) { |id| write_attribute attribute, id }
end

def when_id_exists cardish, &block
  if (card_id = Card.id cardish)
    yield card_id
  elsif cardish.is_a? Card
    with_id_after_store cardish, &block
  else
    yield cardish # eg nil
  end
end

# subcards are usually saved after super cards;
# after_store forces it to save the subcard first
# and callback afterwards
def with_id_after_store subcard
  add_subcard subcard
  subcard.director.after_store { |card| yield card.id }
end
