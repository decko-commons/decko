# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::Admin do
  it "renders a table", as_bot: true do
    assert_view_select render_card(:core, name: :admin), "table"
  end

  describe "#update" do
    let(:admin) { Card[:admin] }

    def run_admin_task task
      Card::Auth.as_bot do
        Card::Env.params[:task] = task
        admin.update({})
      end
    end

    it "clearing trash is denied" do
      expect { run_admin_task :empty_trash }
        .to raise_error Card::Error::PermissionDenied, /The admin task 'Empty Trash'/
    end

    # it "clearing history is denied" do
    #   expect { run_admin_task :clear_history }
    #     .to raise_error Card::Error::PermissionDenied, /The admin task 'clear history'/
    # end

    context "irreversible tasks allowed" do
      around do |example|
        Cardio.config.allow_irreversible_admin_tasks = true
        example.run
        Cardio.config.allow_irreversible_admin_tasks = false
      end

      it "triggers empty trash (with right params)" do
        Card::Auth.as_bot { Card["A"].delete! }

        expect(Card.where(trash: true)).not_to be_empty
        run_admin_task :empty_trash
        expect(Card.where(trash: true)).to be_empty
      end

      # it "triggers deleting old revisions (with right params)" do
      #   Card::Auth.as_bot do
      #     a = Card["A"]
      #     a.update! content: "a new day"
      #     a.update! content: "another day"
      #     expect(a.actions.count).to eq(3)
      #     run_admin_task :clear_history
      #     expect(a.actions.count).to eq(1)
      #   end
      # end
    end

    # it 'is trigger reference repair' do
    #   Card::Auth.as_bot do
    #     a = Card['A']
    #     puts a.references_out.count
    #     Card::Env.params[:task] = :repair_references
    #     puts a.references_out.count
    #     @all.update({})
    #     puts a.references_out.count
    #
    #   end
    # end
  end

  specify "view warning" do
    expect_view(:warning).to have_tag("div.alert.alert-warning.alert-dismissible") do
      with_tag "button.btn-close"
    end
  end
end
