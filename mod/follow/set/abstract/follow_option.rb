def restrictive_option?
  Card::FollowOption.restrictive_options.include? codename
end

def description set_card
  set_card.follow_label
end

# follow option methods on the Card class
# FIXME: there's not a great reason to have these on the Card class
module ClassMethods
  # args:
  # position: <Fixnum> (starting at 1, default: add to end)
  def restrictive_follow_opts args
    add_option args, :restrictive
  end

  # args:
  # position: <Fixnum> (starting at 1, default: add to end)
  def follow_opts args
    add_option args, :main
  end

  def follow_test opts={}, &block
    Card::FollowOption.test[get_codename(opts)] = block
  end

  def follower_candidate_ids opts={}, &block
    Card::FollowOption.follower_candidate_ids[get_codename(opts)] = block
  end

  private

  def insert_option pos, item, type
    list = Card::FollowOption.codenames(type)
    list[pos] ? list.insert(pos, item) : (list[pos] = item)
    # If pos > codenames.size in a previous insert then we have a bunch
    # of preceding nils in the array.
    # Hence, we have to overwrite a nil value if we encounter one and
    # can't use insert.
  end

  def add_option(opts, type, &)
    codename = get_codename opts
    if opts[:position]
      insert_option opts[:position] - 1, codename, type
    else
      Card::FollowOption.codenames(type) << codename
    end
    Card::FollowOption.codenames(:all) << codename
  end

  def get_codename opts
    opts[:codename] || name.match(/::(\w+)$/)[1].underscore.to_sym
  end
end
