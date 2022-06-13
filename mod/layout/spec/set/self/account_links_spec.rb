# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::AccountLinks do
  it "has a 'my card' link" do
    account_links = render_card :core, name: "*account links"
    expect(account_links).to have_tag "div#logging" do
      have_tag 'a[class=~"my-card-link"]', text: "Joe User"
    end
  end

  context "when user doesn't have special roles", with_user: "Joe Camel" do
    it "does not show role interface" do
      expect_view(:my_card, card: :account_links)
        .not_to include "Roles"
    end

    it "shows account settings link" do
      expect_view(:my_card, card: :account_links).to have_tag "ul.dropdown-menu" do
        with_tag :a, text: "Account", with: { href: "/Joe_Camel+*account_settings" }
      end
    end
  end

  context "when user has special roles", with_user: "Joe User" do
    it "shows role interface" do
      expect_view(:my_card, card: :account_links).to have_tag "ul.dropdown-menu" do
        with_tag "li" do
          with_tag ".dropdown-item" do
            with_checkbox "pointer_checkbox-joe_user-Xenabled_role-1", "Anyone Signed In"
            with_tag :a, text: "Anyone Signed In", with: { href: "/Anyone_Signed_In" }
          end
        end
        with_tag :a, text: "Shark", with: { href: "/Shark" }
      end
    end

    it "shows account settings link" do
      expect_view(:my_card, card: :account_links).to have_tag "ul.dropdown-menu" do
        with_tag :a, text: "Account", with: { href: "/Joe_User+*account_settings" }
      end
    end
  end
end
