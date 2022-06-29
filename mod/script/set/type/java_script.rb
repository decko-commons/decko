# -*- encoding : utf-8 -*-

include_set Abstract::JavaScript

require 'ansi2html'
include Ansi2html

event :validate_javascript_syntax, :validate, on: :save, changed: %i[type_id content] do
  Uglifier.compile content, harmony: true
rescue Uglifier::Error => e
  errors.add :content, "<pre>#{ansi2html(e.message)}</pre>".html_safe
end
