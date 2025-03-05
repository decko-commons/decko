%i[be_hidden be_locked].each do |test|
  RSpec::Matchers.define "#{test}_from" do |user|
    match do |card|
      Card::Auth.as(user.id) { expect(card).to send(test) }
    end

    match_when_negated do |card|
      Card::Auth.as(user.id) { expect(card).not_to send(test) }
    end
  end
end

RSpec::Matchers.define :be_hidden do
  user_name = Card::Auth.as_card.name

  match do |card|
    expect(card.ok?(:read)).to be_falsey, "expected #{user_name} can't read #{card.name}"
    expect(Card.search(id: card.id).map(&:name))
      .to be_empty, "expected #{card.name} hidden from #{user_name}"
  end

  match_when_negated do |card|
    expect(card.ok?(:read)).to be_truthy, "expected #{user_name} can read #{card.name}"
    expect(Card.search(id: card.id).map(&:name))
      .to eq([card.name]), "#{card.name} not hidden from #{user_name} "
  end
end

RSpec::Matchers.define :be_locked do
  user_name = Card::Auth.as_card.name
  match do |card|
    expect(card.ok?(:update))
      .to be_falsey, "expected #{card.name} to be locked from #{user_name}"
  end

  match_when_negated do |card|
    expect(card.ok?(:update))
      .to be_truthy, "expected #{card.name} not to be locked from #{user_name}"
  end
end
