# -*- encoding : utf-8 -*-

def self.included host_class
  host_class.extend ClassMethods
  host_class
end

def db_content
  Card::Virtual.fetch_value(self)
end

def update_cached_count _changed_card=nil
  Count.refresh(self)
end

# called to refresh the virtual content
# the default way is to use the card's content method
def generate_virtual_content
  template.db_content
end

def self.pointer_card_changed_card_names card
  return card.item_names if card.trash
  old_changed_card_content = card.last_action.previous_value(:content)
  old_card = Card.new type_id: PointerID, content: old_changed_card_content
  (old_card.item_names - card.item_names) +
    (card.item_names - old_card.item_names)
end

module ClassMethods
  def recount_trigger *set_parts_of_changed_card
    args =
      set_parts_of_changed_card.last.is_a?(Hash) ? set_parts_of_changed_card.pop : {}
    set_of_changed_card = ensure_set { set_parts_of_changed_card }
    args[:on] ||= [:create, :update, :delete]
    name = event_name set_of_changed_card, args
    set_of_changed_card.class_eval do
      event name, :after_integrate do
        # , args.merge(after_all: :refresh_updated_answers) do
        Array.wrap(yield(self)).compact.each do |expired_count_card|
          next unless expired_count_card.respond_to?(:recount)
          expired_count_card.update_cached_count self
        end
      end
    end
  end

  def event_name set, args
    changed_card_set = set.to_s.tr(":", "_").underscore
    virtual_content_set = to_s.tr(":", "_").underscore
    actions = Array.wrap args[:on]
    "update_virtual_content_for_#{virtual_content_set}_due_to_change_in_" \
        "#{changed_card_set}_on_#{actions.join('_')}".to_sym
  end
end
