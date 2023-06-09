class MoveRevisionsToActions < Cardio::Migration::Schema
  class TmpRevision < Cardio::Record
    belongs_to :tmp_card, foreign_key: :card_id
    self.table_name = "card_revisions"
    def self.delete_cardless
      left_join = "LEFT JOIN cards "\
                  "ON card_revisions.card_id = cards.id"
      TmpRevision.joins(left_join).where("cards.id IS NULL").delete_all
    end
  end

  class TmpAct < Cardio::Record
    self.table_name = "card_acts"
  end

  class TmpAction < Cardio::Record
    self.table_name = "card_actions"
  end

  class TmpChange < Cardio::Record
    self.table_name = "card_changes"
  end

  class TmpCard < Cardio::Record
    belongs_to :tmp_revision, foreign_key: :current_revision_id
    has_many :tmp_actions, foreign_key: :card_id
    self.table_name = "cards"
  end

  def up
    TmpRevision.delete_cardless
    TmpRevision.find_each { |rev| migrate_revision rev }
    TmpCard.find_each { |card| update_tmp_card card }
  end

  private

  def conn
    @conn ||= TmpRevision.connection
  end

  def created
    @created ||= ::Set.new
  end

  def migrate_revision rev
    create_tmp_act rev

    if created.include? rev.card_id
      create_update_action rev
    else
      create_create_action rev
    end
  end

  def create_create_action rev
    TmpAction.connection.execute(
      "INSERT INTO card_actions (id, card_id, card_act_id, action_type) VALUES "\
      "('#{rev.id}', '#{rev.card_id}', '#{rev.id}', 0)")
    if (tmp_card = rev.tmp_card)
      TmpChange.connection.execute "INSERT INTO card_changes (card_action_id, field, value) VALUES
              ('#{rev.id}', 0, #{conn.quote tmp_card.name}),
              ('#{rev.id}', 1, '#{tmp_card.type_id}'),
              ('#{rev.id}', 2, #{conn.quote(rev.content)}),
              ('#{rev.id}', 3, #{tmp_card.trash})"
    end
    created.add rev.card_id
  end

  def create_update_action rev
    TmpAction.connection.execute(
      "INSERT INTO card_actions (id, card_id, card_act_id, action_type) VALUES " \
      "('#{rev.id}', '#{rev.card_id}', '#{rev.id}', 1)")
    TmpChange.connection.execute(
      "INSERT INTO card_changes (card_action_id, field, value) VALUES " \
      "('#{rev.id}', 2, #{conn.quote(rev.content)})")
  end

  def create_tmp_act rev
    TmpAct.create id: rev.id, card_id: rev.card_id,
                  actor_id: rev.creator_id, acted_at: rev.created_at
  end

  def update_tmp_card card
    card.update_column(:db_content, card.tmp_revision.content) if card.tmp_revision
  end
end
