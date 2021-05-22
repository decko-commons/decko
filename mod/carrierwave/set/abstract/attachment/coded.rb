event :lose_coded_status_on_update, :initialize, on: :update, when: :coded? do
  # unless explicit
  return if @new_mod

  @new_storage_type ||= storage_type_from_config
end

event :validate_coded_storage_type, :validate, on: :save, when: :will_become_coded? do
  storage_type_error :mod_argument_needed_to_save unless mod || @new_mod
  storage_type_error :codename_needed_for_storage if codename.blank?
end

def storage_type_error error_name
  errors.add :storage_type, t("carrierwave_#{error_name}")
end

def will_become_coded?
  will_be_stored_as == :coded
end

def mod= value
  if @action == :update && mod != value
    @new_mod = value.to_s
  else
    @mod = value.to_s
  end
end
