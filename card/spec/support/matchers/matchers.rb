RSpec::Matchers.define_negated_matcher :not_include, :include
RSpec::Matchers.define_negated_matcher :be_not_virtual, :be_virtual

RSpec::Matchers.define :be_valid do
  match do |card|
    values_match?(true, card.errors.empty?)
  end
end

RSpec::Matchers.define :have_name do |name|
  match do |card|
    values_match?(name, card.name)
  end
end

RSpec::Matchers.define :have_content do |content|
  match do |card|
    values_match?(content, card.content)
  end
end

RSpec::Matchers.define :have_type do |type|
  match do |card|
    case type
    when Symbol
      values_match?(type, card.type_code)
    when Integer
      values_match?(type, card.type_id)
    when String
      values_match?(type, card.type_name)
    end
  end
end

RSpec::Matchers.define :have_raw_content do |content|
  match do |card|
    values_match?(content, card.raw_content)
  end
end

RSpec::Matchers.define :increase_card_count do
  chain(:by) do |diff|
    @diff = diff
  end

  match do |card_creation|
    count = Card.count
    #binding.pry
    card_creation.call
    if @diff
      values_match?(count + @diff, Card.count)
    else
      Card.count > count
    end
  end

  supports_block_expectations
end

RSpec::Matchers.define :be_a_new_card do
  match do |card|
    card.is_a?(Card) && card.new_record?
  end
end

RSpec::Matchers.define :be_invalid do
  match do |card|
    # valid? clears errors
    # For a new card we have to call valid? to create the errors.
    # For a updated card we have to check errors because with valid? we would
    # loose the errors.
    @valid = card.errors.empty? && card.valid?
    # card.errors returns an array, hence we need an extra include matcher
    values_match?(false, @valid) &&
      values_match?(include(@error_msg), card.errors[@error_key])
  end

  description do
    "be invalid #{"because of #{@error_key} #{@error_msg}" if @error_key}"
  end

  chain(:because_of) do |reason|
    @error_key, @error_msg = reason.to_a.first
  end

  failure_message do |actual|
    super() + fail_reason(actual)
  end

  def fail_reason actual
    if @valid
      "but file is valid"
    else
      "but it is invalid because of #{actual.errors.messages}"
    end
  end
end


