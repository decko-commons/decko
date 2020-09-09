def prepare_for_phases
  reset_patterns
  identify_action
  include_set_modules
end

delegate :validation_phase, :storage_phase, :integration_phase,
         :validation_phase_callback?, :integration_phase_callback?, to: :director
