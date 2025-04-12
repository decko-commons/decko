basket[:list_input_options] = %w[radio checkbox select multiselect list autocomplete]

# for override
def delistable?
  true
end

def supports_content_options?
  false
end

def supports_content_option_view?
  false
end
