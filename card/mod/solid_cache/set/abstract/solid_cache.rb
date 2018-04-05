# -*- encoding : utf-8 -*-

# A card that includes Abstract::SolidCache has its "core" view fully rendered
# and stored in a '+*solid cache' card.
# If that card exists the core view returns its content as rendered view.
# If it doesn't exist the usual core view is rendered and saved in that card.
#
# The cache expiration can be controlled with the cache_update_trigger and
# cache_expire_trigger methods.

card_accessor :solid_cache, type: :html

def self.included host_class
  host_class.format(host_class.try(:cached_format) || :base) do
    view :core, cache: :never do
      return super() if voo.hide? :solid_cache
      _render_solid_cache
    end

    view :solid_cache, cache: :never do
      card.with_solid_cache do |cache_card|
        subformat(cache_card)._render_core
      end
    end
  end
end

module ClassMethods
  # If a card of the set given by 'set_of_changed_card' is changed
  # the given block is executed. It is supposed to return an array of
  # cards whose solid caches are expired because of the change.
  # @param set_of_changed_card [set constant] a set of cards that triggers
  #   a cache update
  # @param args [Hash]
  # @option args [Symbol, Array<Symbol>] :on the action(s)
  #   (:create, :update, or :delete) on which the cache update
  #   should be triggered. Default is all actions.
  # @option args [Stage] :in_stage the stage when the update is executed.
  #   Default is :integrate
  # @yield return a card or an array of cards with solid cache that need to be
  #   updated
  def cache_update_trigger set_of_changed_card, args={}, &block
    define_event_to_update_expired_cached_cards(
      set_of_changed_card, args, :update_solid_cache, &block
    )
  end

  # Same as 'cache_update_trigger' but expires instead of updates the
  # outdated solid caches
  def cache_expire_trigger set_of_changed_card, args={}, &block
    define_event_to_update_expired_cached_cards(
      set_of_changed_card, args, :expire_solid_cache, &block
    )
  end

  def define_event_to_update_expired_cached_cards set_of_changed_card, args,
                                                  method_name
    args[:on] ||= %i[create update delete]
    name = event_name set_of_changed_card, args
    stage = args[:in_stage] || :integrate
    Card::Set.register_set set_of_changed_card
    set_of_changed_card.event name, stage, args do
      Array.wrap(yield(self)).compact.each do |expired_cache_card|
        next unless expired_cache_card.solid_cache?
        expired_cache_card.send method_name
      end
    end
  end

  def event_name set, args
    changed_card_set = set.shortname.tr(":", "_").underscore
    solid_cache_set = shortname.tr(":", "_").underscore + "__solid_cache"
    actions = Array.wrap(args[:on]).join("_")
    ["update", solid_cache_set,
     "changed_by", changed_card_set,
     "on", actions].join("___").to_sym
  end
end

def with_solid_cache
  update_solid_cache if solid_cache_card.new?
  yield solid_cache_card
end

def expire_solid_cache _changed_card=nil
  return unless solid_cache? && solid_cache_card.real?
  Auth.as_bot do
    solid_cache_card.delete!
  end
end

def update_solid_cache
  return unless solid_cache?
  new_content = generate_content_for_cache
  write_to_solid_cache new_content
  new_content
end

def generate_content_for_cache
  format_type = try(:cached_format) || :base
  format(format_type)._render_core hide: :solid_cache
end

def write_to_solid_cache new_content
  solid_cache_card.write! new_content
end
