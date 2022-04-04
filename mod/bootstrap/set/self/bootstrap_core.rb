include_set Abstract::BootstrapCodeFile

def load_stylesheets
  add_bs_stylesheet "variables"
  add_bs_stylesheet "rfs", subdir: "vendor"
  %w[
    deprecate
    breakpoints
    color-scheme
    image
    resize
    visually-hidden
    reset-text
    text-truncate
    utilities
    alert
    backdrop
    buttons
    caret
    pagination
    lists
    list-group
    forms
    table-variants
    border-radius
    box-shadow
    gradients
    transition
    clearfix
    container
    grid
  ].each do |name|
    add_bs_stylesheet name, subdir: "mixins"
  end
  %w[
    utilities
    root
    reboot
    type
    images
    containers
    grid
    tables
  ].each do |name|
    add_bs_stylesheet name
  end
  %w[
    labels
    form-text
    form-control
    form-select
    form-check
    form-range
    floating-labels
    input-group
    validation
  ].each do |name|
    add_bs_stylesheet name, subdir: "forms"
  end

  %w[
    buttons
    transitions
    dropdown
    button-group
    nav
    navbar
    card
    accordion
    breadcrumb
    pagination
    badge
    alert
    progress
    list-group
    close
    toasts
    modal
    tooltip
    popover
    carousel
    spinners
    offcanvas
    placeholders
  ].each do |name|
    add_bs_stylesheet name
  end
  %w[
    clearfix
    colored-links
    ratio
    position
    stacks
    visually-hidden
    stretched-link
    text-truncation
    vr
  ].each do |name|
    add_bs_stylesheet name, subdir: "helpers"
  end
  add_bs_stylesheet "api", subdir: "utilities"
end
