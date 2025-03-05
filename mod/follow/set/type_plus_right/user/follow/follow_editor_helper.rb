# all the following methods are used to construct the Follow and Ignore tabs

# TODO: these object representations are complex enough for their own class

format :html do
  # constructs hash of rules/options for "Follow" tab
  def following_rules_and_options &block
    rule_opt_array = following_rule_options_hash.map do |key, val|
      [(Card.fetch key, new: {}), val]
    end
    rules_and_options_by_set_pattern rule_opt_array.to_h, &block
  end

  # constructs hash of rules/options for "Ignore" tab
  def ignoring_rules_and_options &block
    rule_opts_hash = ignore_rules.each_with_object({}) do |rule, hash|
      hash[rule] = [:never.cardname]
    end
    rules_and_options_by_set_pattern rule_opts_hash, &block
  end

  private

  # all rules with ignore
  def ignore_rules
    never = :never.cardname.key
    card.item_cards.select do |follow_rule|
      follow_rule.item_names.any? { |n| n.key == never }
    end
  end

  # @param rule_opts_hash [Hash] { rule1_card => rule1_follow_options }
  # for each rule/option variant, yields with rule_card and option params
  def rules_and_options_by_set_pattern rule_opts_hash
    pattern_hash = a_set_pattern_hash rule_opts_hash
    empty = true
    Pattern.concrete.reverse.map do |pattern|
      pattern_hash[pattern].each do |rule_card, options|
        options.each do |option|
          yield rule_card, option
          empty = false
        end
      end
    end
    yield nil if empty
  end

  def a_set_pattern_hash rule_opts_hash
    pattern_hash = Hash.new { |h, k| h[k] = [] }
    rule_opts_hash.each do |rule_card, options|
      pattern_hash[rule_card.rule_set.subclass_for_set] << [rule_card, options]
    end
    pattern_hash
  end

  # @return Hash # { rule1 => rule1_follow_options }
  def following_rule_options_hash
    merge_option_hashes current_following_rule_options_hash,
                        suggested_following_rule_options_hash
  end

  # adds suggested follow options to existing rules where applicable
  def merge_option_hashes current, suggested
    current.each do |key, current_opt|
      if (suggested_opt = suggested.delete(key))
        current[key] = (current_opt + suggested_opt).uniq
      end
    end
    current.merge suggested
  end

  # @return Hash # { existing_rule1 => rule1_follow_options } (excluding never)
  # (*never is excluded because this list is for the Follow tab, and *never is
  # handled under the Ignore tab)
  def current_following_rule_options_hash
    never = :never.cardname
    card.item_cards.each_with_object({}) do |follow_rule, hash|
      hash[follow_rule.key] = follow_rule.item_names.reject { |item| item == never }
    end
  end

  # @return Hash # { suggested_rule1 => rule1_follow_options }
  def suggested_following_rule_options_hash
    return {} unless card.current_user?

    card.suggestions.each_with_object({}) do |sug, hash|
      set_card, opt = a_set_and_option_suggestion(sug) || a_set_only_suggestion(sug)
      hash[set_card.follow_rule_name(card.trunk).key] = [opt]
    end
  end

  # @param sug [String] follow suggestion
  # @return [Array] set_card and option
  # suggestion value contains both set and follow option
  def a_set_and_option_suggestion sug
    return unless (set_card = valid_set_card(sug.to_name.left))

    [set_card, suggested_follow_option(sug.to_name.right)]
  end

  def suggested_follow_option name
    # FIXME: option should be unambiguously name or codename
    # (if codename use colon or Symbol)
    option_card = Card.fetch(name) || Card[name.to_sym]
    option_card&.follow_option? ? option_card.name : :always.cardname
  end

  # @param sug [String] follow suggestion
  # @return [Array] set_card and option
  # suggestion value contains only set (implies *always)
  def a_set_only_suggestion sug
    return unless (set_card = valid_set_card(sug))

    yield set_card, :always.cardname
  end

  def valid_set_card name
    card = Card.fetch(name)
    card&.type_code == :set ? card : false
  end
end
