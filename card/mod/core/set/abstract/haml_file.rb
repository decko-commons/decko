
def self.included host_class
  host_class.mattr_accessor :template_path
  host_class.extend Card::Set::Format::HamlPaths
  host_class.template_path = host_class.haml_template_path
end

def content
  File.read template_path
end

format :html do
  view :input do
    "Content is managed by code and cannot be edited"
  end

  def haml_locals
    {}
  end

  view :core do
    haml card.content, haml_locals
  end
end
