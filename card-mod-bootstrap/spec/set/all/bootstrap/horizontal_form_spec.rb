# -*- encoding : utf-8 -*-

RSpec.describe Bootstrap::Component::HorizontalForm do
  describe "horizontal form" do
    subject { Card["A"].format(:html) }

    let(:form) do
      subject.bs_horizontal_form 2, 10 do
        group do
          input "email", label: "Email Address", id: "theemail"
          input "password", label: "Password", id: "thepassword"
        end
        group do
          #checkbox "test", label: "checkbox label", id: "thecheckbox"
        end
      end
    end
    let(:bsform) do
      subject.bs do
        horizontal_form 2, 10 do
          group do
            input "email", label: "Email Address", id: "theemail"
            input "password", label: "Password", id: "thepassword"
          end
          group do
            checkbox "test", label: "checkbox label", id: "thecheckbox"
          end
        end
      end
    end

    it "creates form" do
      expect(form).to have_tag 'form.form-horizontal' do
        with_tag 'div.form-group' do
          with_tag 'label.col-sm-2.control-label[for="theemail"]', text: /Email Address/
          with_tag 'div.col-sm-10' do
            with_tag 'input.form-control#theemail[type="email"]'
          end
        end
        # with_tag 'div.form-group' do
        #   with_tag 'input[type="checkbox"]'
        # end
      end
    end
  end
end
