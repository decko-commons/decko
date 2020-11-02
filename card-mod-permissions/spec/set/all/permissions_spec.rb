# -*- encoding : utf-8 -*-

class ::Card
  def writeable_by user
    Card::Auth.as(user.id) do
      # warn "writeable #{Card::Auth.as_id}, #{user.inspect}"
      ok? :update
    end
  end

  def readable_by user
    Card::Auth.as(user.id) do
      ok? :read
    end
  end
end

module PermissionSpecHelper
  def assert_hidden_from user, card, msg=""
    Card::Auth.as(user.id) { assert_hidden(card, msg) }
  end

  def assert_not_hidden_from user, card, msg=""
    Card::Auth.as(user.id) { assert_not_hidden(card, msg) }
  end

  def assert_locked_from user, card, msg=""
    Card::Auth.as(user.id) { assert_locked(card, msg) }
  end

  def assert_not_locked_from user, card, msg=""
    Card::Auth.as(user.id) { assert_not_locked(card, msg) }
  end

  def assert_hidden card, msg=""
    assert !card.ok?(:read)
    assert_equal [], Card.search(id: card.id).map(&:name), msg
  end

  def assert_not_hidden card, msg=""
    assert card.ok?(:read)
    assert_equal [card.name], Card.search(id: card.id).map(&:name), msg
  end

  def assert_locked card, msg=""
    assert_equal false, card.ok?(:update), msg
  end

  def assert_not_locked card, msg=""
    assert_equal true, card.ok?(:update), msg
  end
end

include PermissionSpecHelper

RSpec.describe Card::Set::All::Permissions do
  # FIXME: lots of good tests here, but generally disorganized.

  context "??" do
    before do
      Card::Auth.as_bot do
        # Card::Auth.cache.reset
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
                    content: "[[Anyone Signed In]]"
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

    it "write user permissions" do
      Card::Auth.as_bot do
        (1..3).map do |num|
          Card.create name: "c#{num}+*self+*update", type: "Pointer",
                      content: "[[u#{num}]]"
        end

        Card::Cache.renew

        @u1.fetch(:roles, new: {}).items = [@r1, @r2]
        @u2.fetch(:roles, new: {}).items = [@r1, @r3]
        @u3.fetch(:roles, new: {}).items = [@r1, @r2, @r3]
      end

      @c1 = Card["c1"].refresh(true)
      assert_not_locked_from(@u1, @c1)
      assert_locked_from(@u2, @c1)
      assert_locked_from(@u3, @c1)

      @c2 = Card["c2"].refresh(true)
      assert_locked_from(@u1, @c2)
      assert_not_locked_from(@u2, @c2)
      assert_locked_from(@u3, @c2)
    end

    it "read group permissions" do
      Card::Auth.as_bot do
        @u1.fetch(:roles).items = [@r1, @r2]
        @u2.fetch(:roles).items = [@r1, @r3]

        (1..3).each do |num|
          Card.create name: "c#{num}+*self+*read", type: "Pointer",
                      content: "[[r#{num}]]"
        end
      end

      @c1 = @c1.refresh(true)
      @c2 = @c2.refresh(true)
      @c3 = @c3.refresh(true)

      assert_not_hidden_from(@u1, @c1)
      assert_not_hidden_from(@u1, @c2)
      assert_hidden_from(@u1, @c3)

      assert_not_hidden_from(@u2, @c1)
      assert_hidden_from(@u2, @c2)
      assert_not_hidden_from(@u2, @c3)
    end

    it "write group permissions" do
      Card::Auth.as_bot do
        (1..3).each do |num|
          Card.create name: "c#{num}+*self+*update", type: "Pointer",
                      content: "[[r#{num}]]"
        end

        @u3.fetch(:roles, new: {}).items = [@r1]
      end

      #          u1 u2 u3
      #  c1(r1)  T  T  T
      #  c2(r2)  T  T  F
      #  c3(r3)  T  F  F
      assert_equal true,  @c1.writeable_by(@u1), "c1 writeable by u1"
      assert_equal true,  @c1.writeable_by(@u2), "c1 writeable by u2"
      assert_equal true,  @c1.writeable_by(@u3), "c1 writeable by u3"
      assert_equal true,  @c2.writeable_by(@u1), "c2 writeable by u1"
      assert_equal true,  @c2.writeable_by(@u2), "c2 writeable by u2"
      assert_equal false, @c2.writeable_by(@u3), "c2 writeable by u3"
      assert_equal true,  @c3.writeable_by(@u1), "c3 writeable by u1"
      assert_equal false, @c3.writeable_by(@u2), "c3 writeable by u2"
      assert_equal false, @c3.writeable_by(@u3), "c3 writeable by u3"
    end

    it "read user permissions" do
      Card::Auth.as_bot do
        @u1.fetch(:roles, new: {}).items = [@r1, @r2]
        @u2.fetch(:roles, new: {}).items = [@r1, @r3]
        @u3.fetch(:roles, new: {}).items = [@r1, @r2, @r3]

        (1..3).each do |num|
          Card.create name: "c#{num}+*self+*read", type: "Pointer",
                      content: "[[u#{num}]]"
        end
      end

      @c1 = @c1.refresh(true)
      @c2 = @c2.refresh(true)
      # NOTE: retrieving private cards is known not to work now.
      # assert_not_hidden_from(@u1, @c1)
      # assert_not_hidden_from(@u2, @c2)

      assert_hidden_from(@u2, @c1)
      assert_hidden_from(@u3, @c1)
      assert_hidden_from(@u1, @c2)
      assert_hidden_from(@u3, @c2)
    end

    context "create permissions" do
      before do
        Card::Auth.as_bot do
          Card.create! name: "*structure+*right+*create", type: "Pointer",
                       content: "[[Anyone Signed In]]"
          Card.create! name: "*self+*right+*create",      type: "Pointer",
                       content: "[[Anyone Signed In]]"
        end
      end

      it "inherits" do
        Card::Auth.as(:anyone_signed_in) do
          # explicitly granted above
          expect(Card.fetch("A+*self").ok?(:create)).to be_truthy
          # by default restricted
          expect(Card.fetch("A+*right").ok?(:create)).to be_falsey

          expect(Card.fetch("A+*self+*structure", new: {}).ok?(:create)).to(
            be_truthy # +*structure granted;
          )
          expect(Card.fetch("A+*right+*structure", new: {}).ok?(:create)).to(
            be_falsey # can't create A+B, therefore can't create A+B+C
          )
        end
      end
    end

    it "private cql" do
      # set up cards of type TestType, 2 with nil reader, 1 with role1 reader
      Card::Auth.as_bot do
        [@c1, @c2, @c3].each do |c|
          c.update content: "WeirdWord"
        end
        Card.create(name: "c1+*self+*read", type: "Pointer", content: "[[u1]]")
      end

      Card::Auth.as(@u1) do
        expect(Card.search(content: "WeirdWord").map(&:name).sort).to(
          eq %w[c1 c2 c3]
        )
      end
      Card::Auth.as(@u2) do
        expect(Card.search(content: "WeirdWord").map(&:name).sort).to(
          eq %w[c2 c3]
        )
      end
    end

    it "role cql" do
      # warn "u1 roles #{Card[ @u1.id ].fetch(roles).item_names.inspect}"

      # set up cards of type TestType, 2 with nil reader, 1 with role1 reader
      Card::Auth.as_bot do
        [@c1, @c2, @c3].each do |c|
          c.update content: "WeirdWord"
        end
        Card.create(name: "c1+*self+*read", type: "Pointer", content: "[[r3]]")
      end

      Card::Auth.as(@u1) do
        expect(Card.search(content: "WeirdWord").map(&:name).sort).to(
          eq(%w[c1 c2 c3])
        )
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
    expect(Card.new.ok?(:read)).to be_truthy
  end

  context "default permissions" do
    before do
      @c = Card.create! name: "sky blue"
    end

    it "lets anonymous users view basic cards" do
      Card::Auth.as :anonymous do
        expect(@c.ok?(:read)).to be_truthy
      end
    end

    it "lets joe user basic cards" do
      Card::Auth.as "joe_user" do
        expect(@c.ok?(:read)).to be_truthy
      end
    end
  end

  it "allows anyone signed in to create Basic Cards" do
    expect(Card.new.ok?(:create)).to be_truthy
  end

  it "does not allow someone not signed in to create Basic Cards" do
    Card::Auth.as :anonymous do
      expect(Card.new.ok?(:create)).not_to be_truthy
    end
  end

  context "settings based permissions" do
    before do
      Card::Auth.as_bot do
        @delete_rule_card = Card.fetch "*all+*delete", new: {}
        @delete_rule_card.type_id = Card::PointerID
        @delete_rule_card.db_content = "[[Joe_User]]"
        @delete_rule_card.save!
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
                   subcards: {
                     "+*self+*read" => { content: "[[Administrator]]" }
                   }
      expect(Card["read rule test"].read_rule_class)
        .to eq("*self")
      rule_id = Card.fetch_id "read rule test+*self+*read"
      expect(Card["read rule test"].read_rule_id)
        .to eq(rule_id)
    end
  end


  describe "cardtypes and permissions" do
    specify "cardtype b has create role r1" do
      expect(Card["Cardtype B+*type+*create"]).to have_db_content("[[r3]]")
                                                    .and have_type :pointer
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

