# -*- encoding : utf-8 -*-

describe Bootstrap::Component::Form do
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
            input "email", "Email Address", id: "theemail"
            input "password", "Password", id: "thepassword"
          end
        end
      expect(form).to have_tag :form do
        with_tag "div.form-group" do
          with_tag :label, with: { for: "theemail" },
                           text: "\nEmail Address"
          with_tag "input.form-control", with: { type: "email", id: "theemail" }
        end
      end
    end
  end

  describe "horizontal form" do
    subject { Card["A"].format(:html) }

    let(:form) do
      subject.bs_horizontal_form 2, 10 do
        group do
          input "email", "Email Address", id: "theemail"
          input "password", "Password", id: "thepassword"
        end
        group do
          checkbox "test", "checkbox label", id: "thecheckbox"
        end
      end
    end
    let(:bsform) do
      subject.bs do
        horizontal_form 2, 10 do
          group do
            input "email", "Email Address", id: "theemail"
            input "password", "Password", id: "thepassword"
          end
          group do
            checkbox "test", "checkbox label", id: "thecheckbox"
          end
        end
      end
    end

    it "creates form" do
      expect(bsform).to have_tag 'form.form-horizontal' do
        with_tag 'div.form-group' do
          with_tag 'label[for="theemail"]', text: /Email Address/
          with_tag 'div.col-sm-10' do
            with_tag 'input.form-control#theemail[type="email"]'
          end
        end
      end
    end
  end
end
