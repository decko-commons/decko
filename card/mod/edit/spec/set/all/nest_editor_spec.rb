# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::NestEditor do
  describe "view: nest_editor" do
    def option_row name, value
      with_tag "div._nest-option-row" do
        with_tag :option, with: { selected: "selected", value: name }
        with_tag "input._nest-option-value", with: { value: value }
      end
    end

    def with_field_checked
      with_tag "input._nest-field-toggle", with: { checked: "checked" }
      with_tag "div.input-group-prepend._field-indicator" do
        with_tag "div.input-group-text.text-muted", without: { class: "d-none" }
      end
    end

    def without_field_checked
      with_tag "input._nest-field-toggle", without: { checked: "checked" }
      with_tag "div.input-group-prepend._field-indicator" do
        with_tag "div.input-group-text.text-muted", with: { class: "d-none" }
      end
    end

    def empty_row
      with_tag "div._nest-option-row" do
        with_tag :option, with: { value: "--" }
        with_tag "input._nest-option-value", with: { disabled: "disabled" }
      end
    end

    example "default" do
      expect_view(:nest_editor).to have_tag "div.nest_editor-view" do
        with_tag "input#nest_name", with: { value: ""}
        with_field_checked
        with_tag "div.options-container" do
          option_row :view, :titled
          empty_row
        end
        with_tag "div.options-container" do
          without_tag :h6, /items/
          with_tag :button, "Configure items"
        end
      end
    end

    example "with given field nest sytnax", params: { edit_nest: "{{+hi|view: open; show: menu, toggle|view: titled}}" } do
      expect_view(:nest_editor).to have_tag "div.nest_editor-view" do
        with_tag "input#nest_name", with: { value: "hi"}
        with_field_checked
        with_tag "div.options-container" do
          option_row :view, :open
          option_row :show, :menu
          option_row :show, :toggle
          empty_row
        end
        with_tag "div.options-container" do
          with_tag :h6, /items/
          without_tag :button, "Configure items"
          option_row :view, :titled
          empty_row
        end
      end
    end

    example "with given non-field nest sytnax", params: { edit_nest: "{{hi|view: open; show: menu, toggle}}" } do
      expect_view(:nest_editor).to have_tag "div.nest_editor-view" do
        with_tag "input#nest_name", with: { value: "hi"}
        without_field_checked
        with_tag "div.options-container" do
          option_row :view, :open
          option_row :show, :menu
          option_row :show, :toggle
          empty_row
        end
        with_tag "div.options-container" do
          without_tag :h6, /items/
          with_tag :button, "Configure items"
        end
      end
    end
  end
end
