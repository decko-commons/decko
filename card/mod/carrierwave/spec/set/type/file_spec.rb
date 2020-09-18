# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::File do
  let(:protected_file) do
    card = create_file_card :local
    Card::Auth.as_bot do
      Card.create! name: "#{card.name}+*self+*read",
                   content: "[[Anyone Signed in]]"
    end
    card
  end
  let(:unprotected_file) do
    create_file_card :local, test_file(2), codename: nil
  end

  describe "view: source" do
    def source_view card
      card.format.render!(:source)
    end
    context "storage type: protected" do
      subject { source_view protected_file }

      it "renders protected url to be processed by decko" do
        is_expected.to(
          eq "/files/~#{protected_file.id}/#{protected_file.last_action_id}.txt"
        )
      end
    end

    context "storage type: unprotected" do
      subject { source_view unprotected_file }

      it "renders relative url" do
        is_expected
          .to eq("/files/~#{unprotected_file.id}/#{unprotected_file.last_action_id}.txt")
      end
    end
  end

  context "creating" do
    it "fails if no file given" do
      # ARDEP: exceptions RecordInvalid
      expect do
        Card::Auth.as_bot do
          Card.create! name: "hide and seek", type_id: Card::FileID
        end
      end.to raise_error ActiveRecord::RecordInvalid, "Validation failed: File is missing"
    end

    it "allows no file if 'empty_ok' is true" do
      Card::Auth.as_bot do
        card = Card.create! name: "hide and seek", type_id: Card::FileID, empty_ok: true
        expect(card).to be_instance_of(Card)
        expect(card.content).to eq ""
      end
    end

    it "handles urls as source" do
      url = "https://decko.org/files/bruce_logo-large-122798.png"
      with_storage_config :local do
        file = (create_file_card :local, nil, remote_file_url: url)&.file
        expect(file.size).to be > 0
        expect(file.url).to match(/\.png$/)
      end
    end

    context "storage type:" do
      context "protected" do
        subject { protected_file }

        it "stores correct identifier (~<card id>/<action id>.<ext>)" do
          expect(subject.db_content)
            .to eq "~#{subject.id}/#{subject.last_action_id}.txt"
        end

        it "stores file" do
          expect(File.exist?(subject.file.path)).to be_truthy
          expect(subject.file.read.strip).to eq "file1"
        end

        it "saves original file name as action comment" do
          expect(subject.last_action.comment).to eq "file1.txt"
        end

        it "has correct original filename" do
          expect(subject.original_filename).to eq "file1.txt"
        end

        it "has correct url" do
          expect(subject.file.url).to(
            eq "/files/~#{subject.id}/#{subject.last_action_id}.txt"
          )
        end

        it "doesn't create public symlink" do
          subject
          expect(public_path_exist?).to be_falsey
        end
      end

      context "unprotected" do
        subject { unprotected_file }

        it "creates public symlink" do
          subject
          expect(public_path_exist?).to be_truthy
        end
      end
    end

    context "with subcards" do
      it "handles file subcards" do
        file = File.open(File.join(CARD_TEST_SEED_PATH, "file1.txt"))
        Card.create! name: "new card with file",
                     subcards: { "+my file" => { content: "ignore content",
                                                 type_id: Card::FileID,
                                                 file: file } }
        expect(Card["new card with file+my file"].file.file.read.strip)
          .to eq "file1"
      end
    end
  end

  context "updating" do
    subject do
      card = protected_file
      card.update! file: test_file(2)
      card
    end

    it "updates file" do
      expect(subject.file.read.strip).to eq "file2"
    end

    it "updates original file name" do
      expect(subject.original_filename).to eq "file2.txt"
    end

    it "updates url" do
      expect(subject.file.url)
        .to eq "/files/~#{subject.id}/#{subject.last_action_id}.txt"
    end

    context "when read rules are restricted" do
      subject { unprotected_file }

      it "removes public svmlink" do
        expect(public_path_exist?).to be_truthy
        Card::Auth.as_bot do
          Card.create! name: "#{subject.name}+*self+*read",
                       content: "[[Anyone Signed In]]"
        end
        expect(public_path_exist?).to be_falsey
      end
    end

    context "when read rules changed to 'Anyone'" do
      subject { protected_file }

      it "creates public symlink" do
        expect(public_path_exist?).to be_falsey
        Card::Auth.as_bot do
          Card["#{subject.name}+*self+*read"].delete
        end
        expect(public_path_exist?).to be_truthy
      end
    end
  end

  context "deleting" do
    it "removes symlink for unprotected files" do
      pp = unprotected_file.attachment.public_path
      expect(File.exist?(pp)).to be_truthy
      Card::Auth.as_bot do
        unprotected_file.delete!
      end
      expect(Dir.exist?(File.dirname(pp))).to be_falsey
    end
  end

  def public_path_exist?
    File.exist? public_path
  end

  def public_path
    "public/files/~#{subject.id}/#{subject.last_action_id}.txt"
  end
end
