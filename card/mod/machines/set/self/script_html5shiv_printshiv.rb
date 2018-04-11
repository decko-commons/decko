include_set Abstract::CodeFile

format :html do
  view :script_tag do
    "<!--[if lt IE 9]>"\
    "#{javascript_include_tag card.machine_output_url}"\
    "<![endif]-->"
  end
end
