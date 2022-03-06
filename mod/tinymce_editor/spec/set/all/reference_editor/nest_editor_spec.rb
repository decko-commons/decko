# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::ReferenceEditor::NestEditor do
  describe "view: nest_editor" do
    check_html_views_for_errors

    def option_row name, value, state=:selected
      with_tag "div._nest-option-row" do
        with_tag :option, with: { state => state, value: name }
        with_tag "input._nest-option-value", with: { value: value }
      end
    end

    def with_field_checkbox checked=true
      key = checked ? :with : :without
      with_tag "input._nest-field-toggle", key => { checked: "checked" }
    end

    def with_name name, field=true
      prefix_class = field ? "show-prefix" : "hide-prefix"
      with_tag ".input-group.#{prefix_class}" do
        with_tag "input#nest_name", with: { value: name }
        with_tag "div.input-group-prepend._field-indicator" do
          with_tag "div.input-group-text.text-muted"
        end
      end
    end

    def empty_row
      with_tag "div._nest-option-row" do
        with_tag :option, with: { value: "" }
        with_tag "input._nest-option-value", with: { disabled: :disabled }
      end
    end

    example "default" do
      expect_view(:nest_editor).to have_tag "div.nest_editor-view" do
        with_name "", true
        with_tag "div.options-container" do
          empty_row
        end
        with_tag "div.options-container" do
          without_tag :h6, /items/
          with_tag :button, "Add item options"
          empty_row
        end
      end
    end

    example "with given field nest syntax",
            params: {
              tm_snippet_raw: "{{+hi|view: open; show: menu, toggle|view: titled}}"
            } do
      expect_view(:nest_editor).to have_tag "div.nest_editor-view" do
        with_name "hi", true
        with_tag "._view-select" do
          with_tag :option, with: {  value: :open }
        end
        with_tag "div.options-container" do
          option_row :show, :menu
          option_row :show, :toggle
          empty_row
        end
        with_tag "div.options-container" do
          with_tag :label, /Item options/
          without_tag :button, "Add item options"
          option_row :view, :titled
          empty_row
        end
      end
    end

    example "with given non-field nest syntax",
            params: { tm_snippet_raw: "{{hi|view: open; show: menu, toggle}}" } do
      expect_view(:nest_editor).to have_tag "div.nest_editor-view" do
        with_name "hi", false
        with_tag "._view-select" do
          with_tag :option, with: {  value: :open }
        end
        with_tag "div.options-container" do
          option_row :show, :menu
          option_row :show, :toggle
          empty_row
        end
        with_tag "div.options-container" do
          without_tag :label, /Item  options/
          with_tag :button, "Add item options"
        end
      end
    end
  end
end
