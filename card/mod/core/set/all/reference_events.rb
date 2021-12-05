# on rename, update names in cards that refer to self by name (as directed)
event :update_referer_content, :finalize, on: :update, changed: :name, skip: :allowed do
  referers.each do |card|
    next if card.structure

    card.skip_event! :validate_renaming, :check_permissions
    card.content = card.replace_references name_before_act, name
    subcard card
  end
end

# on rename, when NOT updating referer content, update references to ensure
# that partial references are correctly tracked
# eg.  A links to X+Y.  if X+Y is renamed and we're not updating the link in A,
# then we need to be sure that A has a partial reference
event :update_referer_references_out, :finalize,
      changed: :name, on: :update, when: :skip_update_referers? do
  referers.map(&:update_references_out)
end

# when name changes, update references to card
event :refresh_references_in, :finalize, changed: :name, on: :save do
  Reference.unmap_referees id if action == :update && skip_update_referers?
  Reference.map_referees key, id
end

# when content changes, update references to other cards
event :refresh_references_out, :finalize, on: :save, changed: :content do
  update_references_out
end

# clean up reference table when card is deleted
event :clear_references, :finalize, on: :delete do
  delete_references_out
  Reference.unmap_referees id
end

# replace references in card content
def replace_references old_name, new_name
  cont = content_object
  cont.find_chunks(:Reference).each do |chunk|
    replace_reference chunk, old_name, new_name
  end
  cont.to_s
end

protected

def skip_update_referers?
  skip_event? :update_referer_content
end

private

def replace_reference chunk, old_name, new_name
  return unless (old = chunk.referee_name) && (new = old.swap old_name, new_name)

  chunk.referee_name = chunk.replace_reference old_name, new_name
  update_reference old.key, new.key
end

def update_reference old_key, new_key
  Reference.where(referee_key: old_key).update_all referee_key: new_key
end
