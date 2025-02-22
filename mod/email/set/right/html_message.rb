include_set Abstract::TestContext

# why not?
def clean_html?
  false
end

format :html do
  view :content do
    haml :content_with_link, simple_core: super()
  end
end
