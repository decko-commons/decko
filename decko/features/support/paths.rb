# -*- encoding : utf-8 -*-

module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb

  def url_key index=1
    Regexp.last_match(index).to_name.url_key
  end

  def cgi_val index=1
    CGI.escape Regexp.last_match(index)
  end

  def path_to page_name
    case page_name
    when /the home\s?page/
      "/"
    when /card (.*) with (.*) layout$/
      "/#{url_key}?layout=#{cgi_val 2}"
    when /card (.*)$/
      "/#{url_key}"
    when /new (.*) presetting name to "(.*)" and author to "(.*)"/
      "/new/#{url_key}?card[name]=#{cgi_val 2}&_author=#{cgi_val 3}"
    when /new card named (.*)$/
      "/card/new?card[name]=#{cgi_val}"
    when /edit (.*)$/
      "/#{url_key}/edit"
    when /rename (.*)$/
      "/#{url_key}/edit_name"
    when /new (.*)$/
      "/new/#{url_key}"
    when /url "(.*)"/
      Regexp.last_match(1).to_s
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World(NavigationHelpers)
