include_set Abstract::Machine

store_machine_output filetype: "js"

def ok_to_read
  true
end

view :javascript_include_tag do
  %(
    <script src="#{card.machine_output_url}" type="text/javascript"></script>
  )
end

format :html do
  def raw_help_text
    "JavaScript (or CoffeeScript) for card's page."
  end
end
