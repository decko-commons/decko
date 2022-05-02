# FIXME: this doesn't need to be in ALL set

def read_bootstrap_variables
  path = ::File.expand_path(
    "#{mod_root :bootstrap}/vendor/bootstrap/scss/_variables.scss", __FILE__
  )
  ::File.exist?(path) ? ::File.read(path) : ""
end

format :html do
  view :closed do
    class_up "d0-card-body", "closed-content"
    super()
  end

  include Bootstrapper
end
