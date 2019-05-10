# All cards have one (and only one) of these three states: real, virtual, and unknown.
#
# - *real* cards are stored in the database (but not in the trash) and have a unique id.
# - *virtual* cards are not real, but they act real based on rules. For example,
#   Home+*editors does a search for all the users who have edited the "Home" card.
#   There are other cards that search for references, children, etc. But we don't store
#   all these cards in the database; we generate them dynamically based on the names.
# - *unknown* cards are everything else.
#
# These states are frequently grouped as follows:
#
# - *known* cards are either _real_ or _virtual_
# - *new* (or *unreal*) cards are either _unknown_ or _virtual_

module ClassMethods
  def real? mark
    quick_fetch(mark).present?
  end
  alias :exist? :real?
  alias :exists? :real?

  def known? mark
    fetch(mark).present?
  end
end

def state anti_fishing=true
  case
  when !known?                     then :unknown
  when anti_fishing && !ok?(:read) then :unknown
  when real?                       then :real
  when virtual?                    then :virtual
  else :wtf
  end
end

def real?
  !unreal?
end

def virtual?
  if @virtual.nil?
    @virtual = (real? || name.simple?) ? false : structure.present?
  end
  @virtual
end

def unknown?
  !known?
end

def known?
  real? || virtual?
end

def new?
  new_record? ||       # not yet in db (from ActiveRecord)
    !@from_trash.nil?  # in process of restoration from trash
end
alias :new_card? :new?
alias :unreal? :new?

# has not been edited directly by human users.  bleep blorp.
def pristine?
  new_card? || !actions.joins(:act).where(
    "card_acts.actor_id != ?", Card::WagnBotID
  ).exists?
end

