# -*- encoding : utf-8 -*-

RSpec.describe Bootstrap::Component::Form do
  describe "input" do
    it "has form-group css class" do
      assert_view_select render_editor("Phrase"),
                         'input[type="text"][class~="form-control"]'
    end
  end

  describe "textarea" do
    it "has form-group css class" do
      assert_view_select render_editor("Plain Text"),
                         'textarea[class~="form-control"]'
    end
  end

  describe "form" do
    subject { Card["A"].format(:html) }

    it "creates form" do
      form =
        subject.bs_form do
          group do
            input "email", label: "Email Address", id: "theemail"
            input "password", label: "Password", id: "thepassword"
          end
        end
      expect(form).to have_tag :form do
        with_tag "div.form-group" do
          with_tag :label, with: { for: "theemail" },
                           text: "Email Address"
          with_tag "input.form-control", with: { type: "email", id: "theemail" }
        end
      end
    end
  end
end
