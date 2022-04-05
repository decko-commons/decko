include_set Abstract::BootstrapCodeFile

def load_stylesheets
  add_bs_stylesheet "variables"
  add_bs_stylesheet "rfs", subdir: "vendor"
  mixin_stylesheets.each { |name| add_bs_stylesheet name, subdir: "mixins" }
  main_stylesheets.each { |name| add_bs_stylesheet name }
  form_stylesheets.each { |name| add_bs_stylesheet name, subdir: "forms" }
  after_form_stylesheets.each { |name| add_bs_stylesheet name }
  helper_stylesheets.each { |name| add_bs_stylesheet name, subdir: "helpers" }
  add_bs_stylesheet "api", subdir: "utilities"
end

private

def mixin_stylesheets
  %w[deprecate breakpoints color-scheme image resize visually-hidden reset-text
    text-truncate utilities alert backdrop buttons caret pagination lists list-group
    forms table-variants border-radius box-shadow gradients transition clearfix container
    grid]
end

def main_stylesheets
  %w[ utilities root reboot type images containers grid tables]
end

def form_stylesheets
  %w[labels form-text form-control form-select form-check form-range floating-labels
     input-group validation]
end

def after_form_stylesheets
  %w[buttons transitions dropdown button-group nav navbar card accordion breadcrumb
     pagination badge alert progress list-group close toasts modal tooltip popover
     carousel spinners offcanvas placeholders]
end

def helper_stylesheets
  %w[clearfix colored-links ratio position stacks visually-hidden stretched-link
     text-truncation vr]
end
