include_set Abstract::Css
include_set Abstract::AssetInputter, input_format: :css, input_view: :compressed

# require 'w3c_validators'
require "sass"

event :validate_css, :validate, on: :save, changed: %i[type_id content] do
  # validator = W3CValidators::CSSValidator.new
  # results = validator.validate_text(content)
  # results.errors.each do |error|
  #  errors.add :content, "#{error.message} (line #{error.line})"
  # en
  ::Sass::SCSS::Parser.new(content, nil, nil).parse
rescue ::Sass::SyntaxError => e
  errors.add :content, e.message
end
