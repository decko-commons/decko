# TODO: is this global namespace? module?
def expect_card *marks
  expect Card.cardish(marks)
end

RSpec::Matchers.define :exist do
  match do |card|
    should_be_true =
      case card
      when String
        Card.exist? card
      when Card
        card.real?
      else
        card.present?
      end
    values_match? true, should_be_true
  end

  failure_message do |actual|
    case actual
    when String
      "card '#{actual}' doesn't exist"
    when Card
      "#{actual.name} doesn't exist"
    else
      "#{actual} doesn't exist"
    end
  end
end

RSpec::Matchers.define :be_valid do
  match do |card|
    values_match?(true, card.errors.empty?)
  end
end

%i[name codename db_content type_id left_id right_id].each do |field|
  RSpec::Matchers.define :"have_#{field}" do |name|
    match do |card|
      values_match?(name, card.send(field))
    end

    failure_message do |card|
      super() + ", but was #{card.send(field)}"
    end
  end
end

RSpec::Matchers.define :have_a_field do |field_key|
  chain(:with_content) do |content|
    @content = content
  end

  chain(:pointing_to) do |pointing_to|
    @pointing_to = pointing_to
  end

  chain(:refering_to) do |refering_to|
    @refering_to = refering_to
  end

  match do |card|
    return unless card.is_a?(Card)
    return unless (@field = card.fetch(field_key))

    if @content
      values_match?(@content, @field.content)
    elsif @pointing_to
      @field.is_a?(Card::Set::Abstract::List) && @field.content.include?(@pointing_to)
    elsif @refering_to
      @field.content.include? "[[#{@refering_to}]]"
    else
      values_match Card, @field.class
    end
  end

  failure_message do |card|
    return super() unless @field

    if @content
      "expected #{card} to have a field '#{field_key}' with content '#{@content}',
but content is #{@field.content? ? @field.content : 'empty'}"
    elsif @pointing_to
      "expected #{card} to have a field #{field_key} pointing to #{@pointing_to} but
content is '#{@field.content}'"
    elsif @refering_to
      "expected #{card} to have a field #{field_key} referring to #{@refering_to} but
content is '#{@field.content}'"
    end
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

RSpec::Matchers.define :have_content do |content|
  match do |card|
    values_match?(content, card.content)
  end
end

RSpec::Matchers.define :increase_card_count do
  chain(:by) do |diff|
    @diff = diff
  end

  match do |card_creation|
    count = Card.count
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
