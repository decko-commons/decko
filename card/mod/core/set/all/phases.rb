def prepare_for_phases
  reset_patterns
  Rails.logger.info " - reset_patterns in #prepare_for_phases"
  include_set_modules
end

def only_storage_phase?
  only_storage_phase || !director.main?
end

delegate :validation_phase, to: :director
delegate :storage_phase, to: :director
delegate :integration_phase, to: :director
