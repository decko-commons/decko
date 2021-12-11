# when content changes, update references to other cards
event :refresh_references_out, :finalize, on: :save, changed: :content do
  update_references_out
end

# on rename, update names in cards that refer to self by name (as directed)
event :update_referer_content, :finalize, on: :update, changed: :name, skip: :allowed do
  referers.each { |r| r.replace_references name_before_act, name }
  each_descendant { |d| d.rename_as_descendant !skip_update_referers? }
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

# clean up reference table when card is deleted
event :clear_references, :finalize, on: :delete do
  delete_references_out
  Reference.unmap_referees id
end

protected

def skip_update_referers?
  skip_event? :update_referer_content
end

def rename_as_descendant referers=true
  self.action = :update
  referers ? update_referer_content : update_referer_references_out
  # refresh_references_in
  # refresh_references_out
  expire
  Card::Lexicon.update self
end

def replace_references old_name, new_name
  self.content_quietly = swap_names(old_name, new_name) unless structure
end

def content_quietly= new_content
  self.content = new_content
  return unless db_content_changed? # prevents loops

  update_column :db_content, db_content
  update_references_out
end

private

# delete references from this card
def delete_references_out
  Reference.where(referer_id: id).delete_all if id.present?
end
