include_set Abstract::TestContext

def clean_html?
  false
end

format :email_html do
  def view_caching?
    false
  end
end
