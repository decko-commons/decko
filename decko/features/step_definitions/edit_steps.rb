# -*- encoding : utf-8 -*-
# rubocop:disable Lint/AmbiguousRegexpLiteral, Lint/Syntax, Metrics/LineLength

Given /^(.*) (is|am) watching "([^"]+)"$/ do |user, _verb, cardname|
  Delayed::Worker.new.work_off
  user = Card::Auth.current.name if user == "I"
  signed_in_as user do
    step "the card #{cardname}+#{user}+*follow contains \"[[*always]]\""
  end
end

Given /^(.*) (is|am) not watching "([^"]+)"$/ do |user, _verb, cardname|
  user = Card::Auth.current.name if user == "I"
  signed_in_as user do
    step "the card #{cardname}+#{user}+*follow contains \"[[*never]]\""
  end
end

Given /^the card (.*) contains "([^"]*)"$/ do |cardname, content|
  Card::Auth.as_bot do
    card = Card.fetch cardname, new: {}
    card.content = content
    card.save!
  end
end

When /^(.*) creates?\s*a?\s*([^\s]*) card "([^"]*)" with content "([^"]*)"$/ do |username, cardtype, cardname, content|
  set_content_and_create username, cardtype, cardname, content
end

When /^(.*) creates? Search card "([^"]*)" for cards of type "([^"]*)"$/ do |username, cardname, searchtype|
  set_content_and_create username, "Search", cardname, %({"type":"#{searchtype}"})
end

def set_content_and_create username, cardtype, cardname, content
  create_card(username, cardtype, cardname, content) do
    set_content "card[content]", content, cardtype
  end
end

When /^(.*) creates?\s*([^\s]*) card "([^"]*)"$/ do |username, cardtype, cardname|
  create_card username, cardtype, cardname
end

When /^(.*) creates?\s*([^\s]*) card "([^"]*)" with plusses:$/ do |username, cardtype, cardname, plusses|
  create_card(username, cardtype, cardname) do
    plusses.hashes.first.each do |name, content|
      set_content "card[subcards][+#{name}][content]", content, cardtype
    end
  end
end

When /^(.*) edits? "([^"]*)"$/ do |username, cardname|
  signed_in_as(username) do
    visit "/card/edit/#{cardname.to_name.url_key}"
  end
end

When /^(.*) edits? "([^"]*)" entering "([^"]*)" into wysiwyg$/ do |username, cardname, content|
  signed_in_as(username) do
    visit "/card/edit/#{cardname.to_name.url_key}"
    page.execute_script "$('#main .d0-card-content').val('#{content}')"
    click_button "Submit"
    wait_for_ajax
  end
end

When /^(.*) edits? "([^"]*)" setting (.*) to "([^"]*)"$/ do |username, cardname, _field, content|
  signed_in_as(username) do
    visit "/card/edit/#{cardname.to_name.url_key}"
    set_content "card[content]", content
    click_button "Submit"
    wait_for_ajax
  end
end

When /^(.*) edits? "([^"]*)" filling in "([^"]*)"$/ do |_username, cardname, content|
  visit "/card/edit/#{cardname.to_name.url_key}"
  fill_in "card[content]", with: content
end

When /^(.*) edits? "([^"]*)" with plusses:/ do |username, cardname, plusses|
  signed_in_as(username) do
    visit "/card/edit/#{cardname.to_name.url_key}"
    plusses.hashes.first.each do |name, content|
      set_content "card[subcards][+#{name}][content]", content
    end
    click_button "Submit"
    wait_for_ajax
  end
end

When /^(.*) deletes? "([^"]*)"$/ do |username, cardname|
  signed_in_as(username) do
    visit "/card/delete/#{cardname.to_name.url_key}"
  end
end

def create_card username, cardtype, cardname, content=""
  signed_in_as(username) do
    if cardtype == "Pointer"
      Card.create name: cardname, type: cardtype, content: content
    else
      visit "/card/new?card[name]=#{CGI.escape(cardname)}&type=#{cardtype}"
      yield if block_given?
      click_button "Submit"
      wait_for_ajax
    end
  end
end

def set_content name, content, _cardtype=nil
  Capybara.ignore_hidden_elements = false
  wait_for_ajax
  set_ace_editor_content(name, content) ||
    set_pm_editor_content(name, content) ||
    set_tinymce_editor_content(name, content) ||
    fill_in(name, with: content)
  Capybara.ignore_hidden_elements = true
end

def set_ace_editor_content name, content
  find_editor ".ace-editor-textarea[name='#{name}']" do |_editors|
    return unless page.evaluate_script("typeof ace != 'undefined'")
    sleep(0.5)
    content = escape_quotes content
    page.execute_script "ace.edit($('.ace_editor').get(0))"\
                        ".getSession().setValue('#{content}')"
  end
end

def set_pm_editor_content name, content
  find_editor ".prosemirror-editor > [name='#{name}']" do |editors|
    content = escape_quotes content
    editor_id = editors.first.first(:xpath, ".//..")[:id]
    page.execute_script "$('##{editor_id} .ProseMirror').text('#{content}')"
  end
end

def set_tinymce_editor_content name, content
  find_editor "textarea[name='#{name}']" do |editors|
    editor_id = editors.first[:id]
    return unless page.evaluate_script("typeof tinyMCE != 'undefined' && "\
                                       "tinyMCE.get('#{editor_id}') != null")
    sleep(0.5)
    content = escape_quotes content
    page.execute_script "tinyMCE.get('#{editor_id}').setContent('#{content}')"
  end
end

def escape_quotes content
  content.gsub("'", "\\'")
end

def find_editor selector
  editors = all(selector)
  return unless editors.present?
  yield editors
  true
end

def signed_in_as username
  return yield if same_user?(username)

  preserve_existing_session do
    step "I am signed in as #{username}"
    yield
  end
end

def same_user? username
  (username == "I") || (Card::Auth.current.key == username.to_name.key)
end

def preserve_existing_session
  was_signed_in = Card::Auth.current_id if Card::Auth.signed_in?
  yield
  msg = if was_signed_in
          "I am signed in as #{Card[was_signed_in].name}"
        else
          'I follow "Sign out"'
        end
  step msg
end
