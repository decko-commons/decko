# frozen_string_literal: true

# Cards can refer to other cards in their content, eg via links and nests.
# The card that refers is the "referer", the card that is referred to is
# the "referee". The reference itself has its own class (Card::Reference),
# which handles id-based reference tracking.

PARTIAL_REF_CODE = "P".freeze

# cards that refer to self
def referers
  referer_cards_from_references references_in
end

# cards that include self
def nesters
  referer_cards_from_references references_in.where(ref_type: "I")
end

def referer_cards_from_references references
  references.map(&:referer_id).uniq.map(&Card.method(:fetch)).compact
end

# cards that self refers to
def referees
  referees_from_references references_out
end

# cards that self includes
def nestees
  referees_from_references references_out.where(ref_type: "I")
end

def referees_from_references references
  references.map(&:referee_key).uniq.map { |key| Card.fetch key, new: {} }
end

# cards that refer to self by name
# (finds cards not yet linked by id)
def name_referers
  Card.joins(:references_out).where card_references: { referee_key: key }
end

# replace references in card content
def replace_reference_syntax old_name, new_name
  obj_content = Card::Content.new content, self
  obj_content.find_chunks(Card::Content::Chunk::Reference).select do |chunk|
    next unless (old_ref_name = chunk.referee_name)
    next unless (new_ref_name = old_ref_name.swap old_name, new_name)
    chunk.referee_name = chunk.replace_reference old_name, new_name
    refs = Card::Reference.where referee_key: old_ref_name.key
    refs.update_all referee_key: new_ref_name.key
  end

  obj_content.to_s
end

# delete old references from this card's content, create new ones
def update_references_out
  delete_references_out
  create_references_out
end

# interpret references from this card's content and
# insert entries in reference table
def create_references_out
  ref_hash = {}
  each_reference_out do |referee_name, ref_type|
    interpret_reference ref_hash, referee_name, ref_type
  end
  return if ref_hash.empty?
  Card::Reference.mass_insert reference_values_array(ref_hash)
end

# delete references from this card
def delete_references_out
  raise "id required to delete references" if id.nil?
  Card::Reference.where(referer_id: id).delete_all
end

# interpretation phase helps to prevent duplicate references
# results in hash like:
# { referee1_key: [referee1_id, referee1_type2],
#   referee2_key...
# }
def interpret_reference ref_hash, referee_name, ref_type
  return unless referee_name # eg commented nest has no referee_name
  referee_name = referee_name.to_name
  referee_key = referee_name.key
  return if referee_key == key # don't create self reference

  referee_id = Card::Lexicon.id referee_name
  ref_hash[referee_key] ||= [referee_id]
  ref_hash[referee_key] << ref_type

  interpret_partial_references ref_hash, referee_name unless referee_id
end

# Partial references are needed to track references to virtual cards.
# For example a link to virual card [[A+*self]] won't have a referee_id,
# but when A's name is changed we have to find and update that link.
def interpret_partial_references ref_hash, referee_name
  return if referee_name.simple?
  [referee_name.left, referee_name.right].each do |sidename|
    interpret_reference ref_hash, sidename, PARTIAL_REF_CODE
  end
end

# translate interpreted reference hash into values array,
# removing duplicate and unnecessary ref_types
def reference_values_array ref_hash
  values = []
  ref_hash.each do |referee_key, hash_val|
    referee_id = hash_val.shift || "null"
    ref_types = hash_val.uniq
    ref_types.delete PARTIAL_REF_CODE if ref_types.size > 1
    # partial references are not necessary if there are explicit references
    ref_types.each do |ref_type|
      values << [id, referee_id, "'#{referee_key}'", "'#{ref_type}'"]
    end
  end
  values
end

# invokes the given block for each reference in content with
# the reference name and reference type
def each_reference_out
  content_object.find_chunks(Card::Content::Chunk::Reference).each do |chunk|
    yield chunk.referee_name, chunk.reference_code
  end
end

def has_nests?
  content_object.has_chunk? Card::Content::Chunk::Nest
end

def content_object
  Card::Content.new content, self
end

protected

# test for updating referer content
event :prepare_referer_update, :validate, on: :update, changed: :name do
  self.update_referers = ![nil, false, "false"].member?(update_referers)
end

# on rename, update names in cards that refer to self by name (as directed)
event :update_referer_content, :finalize, on: :update, when: :update_referers do
  referers.each do |card|
    next if card.structure
    card.skip_event! :validate_renaming, :check_permissions
    card.content = card.replace_reference_syntax name_before_act, name
    attach_subcard card
  end
end

# on rename, when NOT updating referer content, update references to ensure
# that partial references are correctly tracked
# eg.  A links to X+Y.  if X+Y is renamed and we're not updating the link in A,
# then we need to be sure that A has a partial reference
event :update_referer_references_out, :finalize,
      on: :update, when: :not_update_referers do
  referers.map(&:update_references_out)
end

# when name changes, update references to card
event :refresh_references_in, :finalize, on: :save do
  Card::Reference.unmap_referees id if action == :update && !update_referers
  Card::Reference.map_referees key, id
end

# when content changes, update references to other cards
event :refresh_references_out, :finalize, on: :save, changed: :content do
  update_references_out
end

# clean up reference table when card is deleted
event :clear_references, :finalize, on: :delete do
  delete_references_out
  Card::Reference.unmap_referees id
end

def not_update_referers
  !update_referers
end
