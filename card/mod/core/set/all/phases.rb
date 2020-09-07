def prepare_for_phases
  reset_patterns
  identify_action
  include_set_modules
end

delegate :validation_phase, to: :director
delegate :storage_phase, to: :director
delegate :integration_phase, to: :director
delegate :only_storage_phase?, to: :director