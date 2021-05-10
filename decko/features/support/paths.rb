# -*- encoding : utf-8 -*-

module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb

  def url_key match, index=1
    match[index].to_name.url_key
  end

  def cgi_val index=1
    CGI.escape match[index]
  end

  def path_to page_name
    case page_name
    when /the home\s?page/
      "/"
    when /card (.*) with (.*) layout$/
      "/#{url_key Regexp.last_match}?layout=#{cgi_val Regexp.last_match, 2}"
    when /card (.*)$/
      "/#{url_key Regexp.last_match}"
    when /new (.*) presetting name to "(.*)" and author to "(.*)"/
      m = Regexp.last_match
      "/new/#{url_key m}?card[name]=#{cgi_val m, 2}&_author=#{cgi_val m, 3}"
    when /new card named (.*)$/
      "/card/new?card[name]=#{cgi_val Regexp.last_match}"
    when /edit (.*)$/
      "/#{url_key Regexp.last_match}/edit"
    when /rename (.*)$/
      "/#{url_key Regexp.last_match}/edit_name"
    when /new (.*)$/
      "/new/#{url_key Regexp.last_match}"
    when /url "(.*)"/
      Regexp.last_match(1).to_s
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World(NavigationHelpers)
