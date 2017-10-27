# -*- encoding : utf-8 -*-

require "card/action"

describe Card, "deleting card" do
  it "requires permission" do
    a = Card["a"]
    Card::Auth.as :anonymous do
      expect(a.ok?(:delete)).to eq(false)
      expect(a.delete).to eq(false)
      expect(a.errors[:permission_denied]).not_to be_empty
      expect(Card["a"].trash).to eq(false)
    end
  end
end

describe Card, "in trash" do
  it "is retrieved by fetch with new" do
    Card.create(name: "Betty").delete
    c = Card.fetch "Betty", new: {}
    c.save
    expect(Card["Betty"]).to be_instance_of(Card)
  end
end

describe Card, "plus cards" do
  it "is deleted when root is" do
    Card::Auth.as "joe_admin" do
      c = Card.create! name: "zz+top"
      root = Card["zz"]
      root.delete
      #      Rails.logger.info "ERRORS = #{root.errors.full_messages*''}"
      expect(Card.find(c.id).trash).to be_truthy
      expect(Card["zz"]).to be_nil
    end
  end
end

# NOT WORKING, BUT IT SHOULD
# describe Card, "a part of an unremovable card" do
#  before do
#     Card::Auth.as(Card::WagnBotID)
#     # this ugly setup makes it so A+Admin is the actual user with edits..
#     Card["Wagn Bot"].update_attributes! name: "A+Wagn Bot"
#  end
#  it "does not be removable" do
#    @a = Card['A']
#    @a.delete.should_not be_true
#  end
# end

describe Card, "rename to trashed name" do
  before do
    Card::Auth.as_bot do
      @a = Card["A"]
      @b = Card["B"]
      @a.delete!  # trash
      @b.update_attributes! name: "A", update_referers: true
    end
  end

  it "renames b to a" do
    expect(@b.name).to eq("A")
  end

  it "renames a to a*trash" do
    expect((c = Card.find(@a.id)).name.to_s).to eq("A*trash")
    expect(c.name).to eq("A*trash")
    expect(c.key).to eq("a*trash")
  end
end

describe Card, "sent to trash" do
  before do
    Card::Auth.as_bot do
      @c = Card["basicname"]
      @c.delete!
    end
  end

  it "is trash" do
    expect(@c.trash).to eq(true)
  end

  it "does not be findable by name" do
    expect(Card["basicname"]).to eq(nil)
  end

  it "still has actions" do
    expect(@c.actions.count).to eq(2)
    expect(@c.last_change_on(:db_content).value).to eq("basiccontent")
  end
end

describe Card, "revived from trash" do
  before do
    Card::Auth.as_bot do
      Card["basicname"].delete!

      @c = Card.create! name: "basicname", content: "revived content"
    end
  end

  it "does not be trash" do
    expect(@c.trash).to eq(false)
  end

  it "has 3 actions" do
    expect(@c.actions.count).to eq(3)
  end

  it "still has old content" do
    expect(@c.nth_action(1).value :db_content).to eq("basiccontent")
  end

  it "has the same content" do
    expect(@c.content).to eq("revived content")
    #    Card.fetch(@c.name).content.should == 'revived content'
  end
end

describe Card, "recreate trashed card via new" do
  #  before do
  #    Card::Auth.as(Card::WagnBotID)
  #    @c = Card.create! type: 'Basic', name: "BasicMe"
  #  end

  #  this test is known to be broken; we've worked around it for now
  #  it "deletes and recreate with a different cardtype" do
  #    @c.delete!
  #    @re_c = Card.new type: "Phrase", name: "BasicMe", content: "Banana"
  #    @re_c.save!
  #  end
end

describe Card, "junction revival" do
  before do
    Card::Auth.as_bot do
      @c = Card.create! name: "basicname+woot", content: "basiccontent"
      @c.delete!
      @c = Card.create! name: "basicname+woot", content: "revived content"
    end
  end

  it "isn't trash" do
    expect(@c.trash).to eq(false)
  end

  it "has 3 actions" do
    expect(@c.actions.count).to eq(3)
  end

  it "still has old action" do
    expect(@c.nth_action(1).value :db_content).to eq("basiccontent")
  end

  it "has old content" do
    expect(@c.db_content).to eq("revived content")
  end
end

describe "remove tests" do
  # I believe this is here to test a bug where cards with certain kinds of references
  # would fail to delete.  probably less of an issue now that delete is done through
  # trash.
  it "test_remove" do
    assert Card["A"].delete!, "card should be deleteable"
    assert_nil Card["A"]
  end

  example "recreate plus card name variant" do
    Card.create(name: "rta+rtb").delete
    Card["rta"].update_attributes name: "rta!"
    Card.create! name: "rta!+rtb"
    expect(Card["rta!+rtb"]).to be_a Card
    expect(Card["rta!+rtb"].trash).to be_falsey
    expect(Card.find_by_key("rtb*trash")).to be_nil
  end

  example "multiple trash collision" do
    Card.create(name: "alpha").delete
    3.times do
      b = Card.create(name: "beta")
      b.name = "alpha"
      assert b.save!
      b.delete
    end
  end
end
