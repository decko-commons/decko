# -*- encoding : utf-8 -*-
require "decko/rest_spec_helper"

Decko::RestSpecHelper.describe_api do
  describe "#read" do
    context "css" do
      before do
        @all_style = Card["#{Card[:all].name}+#{Card[:style].name}"]
        @all_style.reset_machine_output
      end

      it "creates missing machine output file" do
        args = { params: { mark: @all_style.machine_output_card.name,
                           format: "css",
                           explicit_file: true } }
        get :read, args
        # output_card = Card[:all, :style, :machine_output]
        expect(response).to redirect_to(@all_style.machine_output_url)
        get :read, args
        expect(response.status).to eq(200)
        expect(response.content_type).to eq("text/css")
      end
    end

    context "js" do
      let(:all_js) { Card[:all, :script] }

      it "has correct MIME type" do
        get :read, params: { mark: all_js.machine_output_card.name, format: "js" }
        expect(response.status).to eq 200
        expect(response.content_type).to eq "text/javascript"
      end
    end

    context "jpg" do
      before do
        Card::Auth.as_bot do
          Card.create! name: "mao2", type_code: "image",
                       image: File.new(File.join(CARD_TEST_SEED_PATH, "mao2.jpg"))
          Card.create! name: "mao2+*self+*read", content: "[[Administrator]]"
        end
      end

      it "handles image with no read permission" do
        get :read, params: { mark: "mao2" }
        assert_response 403, "denies html card view"
        get :read, params: { mark: "mao2", format: "jpg" }
        assert_response 403, "denies simple file view"
      end

      it "handles image with read permission" do
        login_as "joe_admin"
        get :read, params: { mark: "mao2" }
        assert_response 200
        get :read, params: { mark: "mao2", format: "jpg" }
        assert_response 200
      end
    end
  end

  describe "#asset" do
    it "serves file" do
      filename = "asset-test.txt"
      # args = { id: filename, format: "txt", explicit_file: true }
      path = File.join(Decko::Engine.paths["gem-assets"].existent.first, filename)
      File.open(path, "w") { |f| f.puts "test" }
      # args = { filename: filename.to_s }
      visit "/assets/#{filename}"
      expect(page.body).to eq "test\n"
      FileUtils.rm path
    end

    it "denies access to other directories" do
      get :asset, params: { mark: "/../../Gemfile" }
      expect(response.status).to eq(404)
    end
  end
end
