# All cards have one (and only one) of these three states: real, virtual, and unknown.
#
# - *real* cards are stored in the database (but not in the trash) and have a unique id.
# - *virtual* cards are not real, but they act real based on rules. For example,
#   Home+*editors does a search for all the users who have edited the "Home" card.
#   There are many other similar cards that search for things like references, children,
#   etc. But we don't store all these cards in the database; we generate them dynamically
#   based on the names.
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
  alias exist? real?
  alias exists? real?

  def known? mark
    fetch(mark).present?
  end
end

# @return [Symbol] :real, :virtual, or :unknown
def state anti_fishing=true
  case
  when !known?                     then :unknown
  when anti_fishing && !ok?(:read) then :unknown
  when real?                       then :real
  when virtual?                    then :virtual
  else :wtf
  end
end

# @return [True/False]
def real?
  !unreal?
end

# Virtual cards are structured, compound cards that are not stored in the database. You
# can create virtual cards with structure rules.
#
# Some cards with hard-coded content will also override the #virtual? method. This
# is established practice, but it is NOT advisable to override any of the other
# state methods.
#
# @return [True/False]
def virtual?
  if @virtual.nil?
    @virtual = real? || name.simple? ? false : structure.present?
  end
  @virtual
end

# @return [True/False]
def unknown?
  !known?
end

# @return [True/False]
def known?
  real? || virtual?
end

# @return [True/False]
def new?
  # ARDEP: new_record? in storage API
  new_record? ||       # not yet in db (from ActiveRecord)
    !@from_trash.nil?  # in process of restoration from trash
end
alias new_card? new?
alias unreal? new?

# has not been edited directly by human users.  bleep blorp.
def pristine?
  new_card? || !user_changes?
end

def user_changes?
  actions.joins(:act).where("card_acts.actor_id != ?", WagnBotID).exists?
end
