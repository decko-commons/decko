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
    Card[oldname].update_attributes! name: newname, update_referers: true
  end
end

def name
  super.to_name
end

def name= newname
  cardname = superize_name newname.to_name
  newkey = cardname.key
  self.key = newkey if key != newkey
  update_subcard_names cardname
  write_attribute :name, cardname.s
end

def superize_name cardname
  return cardname unless @supercard
  @raw_name = cardname.s
  @supercard.subcards.rename key, cardname.key
  @superleft = @supercard if cardname.field_of? @supercard.name
  cardname.absolute_name @supercard.name
end

def key= newkey
  was_in_cache = Card.cache.soft.delete key
  write_attribute :key, newkey
  # keep the soft cache up-to-date
  Card.write_to_soft_cache self if was_in_cache
  # reset the old name - should be handled in tracked_attributes!!
  reset_patterns_if_rule
  reset_patterns
  newkey
end

def update_subcard_names new_name, name_to_replace=nil
  return unless @subcards
  subcards.each do |subcard|
    # if subcard has a relative name like +C
    # and self is a subcard as well that changed from +B to A+B then
    # +C should change to A+B+C. #replace doesn't work in this case
    # because the old name +B is not a part of +C
    name_to_replace ||=
      if subcard.name.junction? &&
         subcard.name.parts.first.empty? &&
         new_name.parts.first.present?
        # replace the empty part
        "".to_name
      else
        name
      end
    subcard.name = subcard.name.swap name_to_replace, new_name.s
    subcard.update_subcard_names new_name, name
  end
end

def autoname name
  if Card.exists?(name) || ActManager.include?(name)
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
  when @superleft then @superleft
  when attribute_is_changing?(:name) && name.to_name.trunk_name.key == name_before_act.to_name.key
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

def fields
  field_names.map { |name| Card[name] }
end

def field_names parent_name=nil
  child_names parent_name, :left
end

def children
  child_names.map { |name| Card[name] }
end

def child_names parent_name=nil, side=nil
  # eg, A+B is a child of A and B
  parent_name ||= name
  side ||= parent_name.to_name.simple? ? :part : :left
  Card.search({ side => parent_name, return: :name },
              "(#{side}) children of #{parent_name}")
end

# ids of children and children's children
def descendant_ids parent_id=nil
  return [] if new_card?
  parent_id ||= id
  Auth.as_bot do
    child_ids = Card.search part: parent_id, return: :id
    child_descendant_ids = child_ids.map { |cid| descendant_ids cid }
    (child_ids + child_descendant_ids).flatten.uniq
  end
end

# children and children's children
# NOTE - set modules are not loaded
# -- should only be used for name manipulations
def descendants
  @descendants ||= descendant_ids.map { |id| Card.quick_fetch id }
end

def repair_key
  Auth.as_bot do
    correct_key = name.key
    current_key = key
    return self if current_key == correct_key

    if (key_blocker = Card.find_by_key_and_trash(correct_key, true))
      key_blocker.name = key_blocker.name + "*trash#{rand(4)}"
      key_blocker.save
    end

    saved =   (self.key = correct_key) && save!
    saved ||= (self.name = current_key) && save!

    if saved
      descendants.each(&:repair_key)
    else
      Rails.logger.debug "FAILED TO REPAIR BROKEN KEY: #{key}"
      self.name = "BROKEN KEY: #{name}"
    end
    self
  end
rescue StandardError
  Rails.logger.info "BROKE ATTEMPTING TO REPAIR BROKEN KEY: #{key}"
  self
end

def right_id= card_or_id
  write_card_or_id :right_id, card_or_id
end

def left_id= card_or_id
  write_card_or_id :left_id, card_or_id
end

def type_id= card_or_id
  write_card_or_id :type_id, card_or_id
end

def write_card_or_id attribute, card_or_id
  if card_or_id.is_a? Card
    write_attribute_to_card attribute, card_or_id
  else
    write_attribute attribute, card_or_id
  end
end

def write_attribute_to_card attribute, card
  if card.id
    write_attribute attribute, card.id
  else
    add_subcard card
    card.director.prior_store = true
    with_id_when_exists(card) do |id|
      write_attribute attribute, id
    end
  end
end

def with_id_when_exists card, &block
  card.director.call_after_store(&block)
end
