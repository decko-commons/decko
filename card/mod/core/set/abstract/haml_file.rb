
def self.included host_class
  host_class.mattr_accessor :template_path
  host_class.extend Card::Set::Format::HamlViews
  host_class.template_path = host_class.haml_template_path
end

def content
  File.read template_path
end

format :html do
  def haml_locals
    {}
  end

  view :core do
    haml card.content, haml_locals
  end
end
