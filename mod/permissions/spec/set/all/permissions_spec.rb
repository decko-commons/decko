# -*- encoding : utf-8 -*-


RSpec::Matchers.define :be_writeable do |user|
  match do |card|
    Card::Auth.as(user.id) { card.ok? :update }
  end
end

RSpec::Matchers.define :be_readable_by do |user|
  match do |card|
    Card::Auth.as(user.id) { card.ok? :read }
  end
end

RSpec::Matchers.define :be_hidden_from do |user|
  match do |card|
    Card::Auth.as(user.id) { expect(card).to be_hidden }
  end

  match_when_negated do |card|
    Card::Auth.as(user.id) { expect(card).not_to be_hidden }
  end
end

RSpec::Matchers.define :be_locked_from do |user|
  match do |card|
    Card::Auth.as(user.id) { expect(card).to be_locked }
  end

  match_when_negated do |card|
    Card::Auth.as(user.id) { expect(card).not_to be_locked }
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
  match do |card|
    expect(card.ok?(:update))
      .to be_falsey, "expected #{Card::Auth.as_card.name} to be locked from #{card.name}"
  end

  match_when_negated do |card|
    expect(card.ok?(:update))
          .to be_truthy, "expected #{Card::Auth.as_card.name} not to be locked from #{card.name}"
  end
end


RSpec.describe Card::Set::All::Permissions do
  # FIXME: lots of good tests here, but generally disorganized.

  def create_self_rule num, grantee, task=:read
      Card::Auth.as_bot do
        Card.create! name: ["c#{num}", :self, task], content: "#{grantee}#{num}"
        Card::Cache.reset_all
      end
    end

  def create_self_role_rule num, task=:read
    create_self_rule num, "r", task
  end

  def create_self_user_rule num, task=:read
    create_self_rule num, "u", task
    end

  context "??" do
    before do
      Card::Auth.as_bot do
        @u1, @u2, @u3, @r1, @r2, @r3, @c1, @c2, @c3 =
          %w[u1 u2 u3 r1 r2 r3 c1 c2 c3].map { |x| Card[x] }
      end
    end

    it "checking ok read should not add to errors" do
      Card::Auth.as_bot do
        expect(Card::Auth.always_ok?).to eq(true)
      end
      Card::Auth.as("joe_user") do
        expect(Card::Auth.always_ok?).to eq(false)
      end
      Card::Auth.as("joe_admin") do
        expect(Card::Auth.always_ok?).to eq(true)
        Card.create! name: "Hidden"
        Card.create name: "Hidden+*self+*read", type: "Pointer",
                    content: "Anyone Signed In"
      end

      Card::Auth.as(:anonymous) do
        h = Card.fetch("Hidden")
        expect(h.ok?(:read)).to eq(false)
        expect(h.errors.empty?).not_to eq(nil)
      end
    end

    it "reader setting", aggregate_failures: true do
      Card.where(trash: false).each do |ca|
        rule_id, rule_class = ca.permission_rule_id_and_class :read
        expect(ca.read_rule_class).to eq(rule_class),
                                      "read rule class mismatch for #{ca.name}"
        expect(ca.read_rule_id).to eq(rule_id),
                                   "read rule id mismatch for #{ca.name}"
      end
    end

    context "read user permissions" do
      it "user can read all cards with read rules granted to him" do
        create_self_user_rule 1
        create_self_user_rule 2
        expect(@c1).not_to be_hidden_from @u1
        expect(@c2).not_to be_hidden_from @u2
      end

      it "user can't read cards without read rules granted to him" do
        create_self_user_rule 3
        # Card::Cache.reset_all
        expect(Card["c3"]).to be_hidden_from @u2
      end

      it "admin can read cards even without read rules granted to him" do
        create_self_user_rule 2
        expect(@c3).not_to be_hidden_from @u3
      end
    end


    context "write user permissions" do
      it "user can edit all cards with update rules granted to him" do
        create_self_user_rule 1, :update
        create_self_user_rule 2, :update
        expect(@c1).not_to be_locked_from @u1
        expect(@c2).not_to be_locked_from @u2
      end

      it "user can't edit cards without update rules granted to him" do
        create_self_user_rule 1, :update
        create_self_user_rule 2, :update
        expect(Card["c1"]).to be_locked_from @u2
        expect(Card["c2"]).to be_locked_from @u1
      end

      it "admin can edit cards even without read rules granted to him" do
        create_self_user_rule 2
        expect(@c3).not_to be_locked_from @u3
      end
    end

    context "read group permissions" do
      it "user can read all cards with read rules granted to his roles" do
        create_self_role_rule 1
        create_self_role_rule 2
        expect(@c1).not_to be_hidden_from @u1
        expect(@c2).not_to be_hidden_from @u2
      end

      it "user can't read cards without read rules granted to his roles" do
        create_self_role_rule 3
        expect(Card["c3"]).to be_hidden_from @u2
      end

      it "admin can read cards even without read rules granted to his roles" do
        create_self_role_rule 2
        expect(@c2).not_to be_hidden_from @u3
      end
    end

    context "write group permissions" do
      it "user can write all cards with update rules granted to his roles" do
        create_self_role_rule 1, :update
        expect(@c1).not_to be_locked_from @u1
        expect(@c2).not_to be_locked_from @u1
      end

      it "user can't write cards without update rules granted to his roles" do
        create_self_role_rule 3, :update
        expect(Card["c3"]).to be_locked_from @u2
      end

      it "admin can write cards even without update rules granted to his roles" do
        create_self_role_rule 2, :update
        expect(@c1).not_to be_locked_from @u3
      end
    end

    context "create permissions" do
      before do
        Card::Auth.as_bot do
          Card.create! name: "*structure+*right+*create", type: "Pointer",
                       content: "Anyone Signed In"
          Card.create! name: "*self+*right+*create",      type: "Pointer",
                       content: "Anyone Signed In"
        end
      end

      it "inherits" do
        Card::Auth.as(:anyone_signed_in) do
          # explicitly granted above
          expect(Card.fetch("A+*self")).to be_ok(:create)
          # by default restricted
          expect(Card.fetch("A+*right")).not_to be_ok(:create)

          expect(Card.fetch("A+*self+*structure", new: {})).to(
            be_ok(:create) # +*structure granted;
          )
          expect(Card.fetch("A+*right+*structure", new: {})).not_to(
            be_ok(:create) # can't create A+B, therefore can't create A+B+C
          )
        end
      end
    end

    it "private cql" do
      # set up cards of type TestType, 2 with nil reader, 1 with role1 reader
      Card::Auth.as_bot do
        [@c1, @c2, @c3].each { |c| c.update content: "WeirdWord" }
        Card.create(name: "c1+*self+*read", type: "Pointer", content: "u1")
      end

      Card::Auth.as(@u1) do
        expect(Card.search(content: "WeirdWord").map(&:name).sort).to(eq %w[c1 c2 c3])
      end
      Card::Auth.as(@u2) do
        expect(Card.search(content: "WeirdWord").map(&:name).sort).to(eq %w[c2 c3])
      end
    end

    it "role cql" do
      # warn "u1 roles #{Card[ @u1.id ].fetch(roles).item_names.inspect}"

      # set up cards of type TestType, 2 with nil reader, 1 with role1 reader
      Card::Auth.as_bot do
        [@c1, @c2, @c3].each { |c| c.update content: "WeirdWord" }
        Card.create(name: "c1+*self+*read", type: "Pointer", content: "r3")
      end

      Card::Auth.as(@u1) do
        expect(Card.search(content: "WeirdWord").map(&:name).sort).to(eq(%w[c1 c2 c3]))
      end
      # for Card::Auth.as to be effective, you can't have a logged in user
      Card::Auth.signin nil
      Card::Auth.as(@u2) do
        expect(Card.search(content: "WeirdWord").map(&:name).sort).to(
          eq(%w[c2 c3])
        )
      end
    end

    def permission_matrix
      # TODO
      # generate this graph three ways:
      # given a card with editor in group X, can Y edit it?
      # given a card with reader in group X, can Y view it?
      # given c card with group anon, can Y change the reader/writer to X

      # X,Y in Anon, auth Member, auth Nonmember, admin

      %(
    A V C J G
  A * * * * *
  V * * . * .
  C * * * . .
  J * * . . .
  G * . . . .
  )
    end
  end

  it "lets joe view new cards" do
    expect(Card.new).to be_ok(:read)
  end

  context "default permissions" do
    before { c }
    let(:c) { Card.create! name: "sky blue" }

    it "lets anonymous users view basic cards" do
      Card::Auth.as :anonymous do
        expect(c).to be_ok(:read)
      end
    end

    it "lets joe user basic cards" do
      Card::Auth.as "joe_user" do
        expect(c).to be_ok(:read)
      end
    end
  end

  it "allows anyone signed in to create Basic Cards" do
    expect(Card.new).to be_ok(:create)
  end

  it "does not allow someone not signed in to create Basic Cards" do
    Card::Auth.as :anonymous do
      expect(Card.new).not_to be_ok(:create)
    end
  end

  context "settings based permissions" do
    before do
      Card::Auth.as_bot do
        Card.fetch("*all+*delete", new: {}).update! type_code: :pointer,
                                                    content: "Joe User"
      end
    end

    it "handles delete as a setting" do
      c = Card.new name: "whatever"
      expect(c.who_can(:delete)).to eq([Card["joe_user"].id])
      Card::Auth.as("joe_user") do
        expect(c.ok?(:delete)).to eq(true)
      end
      Card::Auth.as("u1") do
        expect(c.ok?(:delete)).to eq(false)
      end
      Card::Auth.as(:anonymous) do
        expect(c.ok?(:delete)).to eq(false)
      end
      Card::Auth.as_bot do
        expect(c.ok?(:delete)).to eq(true) # because administrator
      end
    end
  end

  it "create read rule as subcard" do
    Card::Auth.as_bot do
      Card.create! name: "read rule test",
                   subcards: { "+*self+*read" => { content: "Administrator" } }
      expect(Card["read rule test"].read_rule_class)
        .to eq("*self")
      rule_id = "read rule test+*self+*read".card_id
      expect(Card["read rule test"].read_rule_id)
        .to eq(rule_id)
    end
  end

  describe "cardtypes and permissions" do
    specify "cardtype b has create role r1" do
      expect(Card["Cardtype B+*type+*create"])
        .to have_db_content("r3").and have_type(:list)
    end

    example "changing cardtype needs new cardtype's create permission", with_user: "u2" do
      # u3 can update but not create cardtype b
      c = Card["basicname"]
      c.update type: "cardtype_b"

      expect(c.errors[:permission_denied])
        .to include(/You don't have permission to change to this type/)
      expect(Card["basicname"]).to have_type :basic
    end

    # example "changing cardtype needs new cardtype's create permission", with: "u1" do
    #   update! "basicname", type: "cardtype_b"
    #   expect { update! "basicname", content: "new content" }
    #     .to raise_error(/You don't have permission to change to this type/)
    # end
  end
end
