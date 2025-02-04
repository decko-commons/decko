event :validate_codename, :validate, on: :update, changed: :codename do
  validate_codename_permission
  validate_codename_uniqueness
  validate_codename_simplicity
end

event :reset_codename_cache, :integrate, changed: :codename do
  return if action == :create && codename.nil?

  Card::Codename.reset_cache
  Card::Codename.generate_id_constants
end

private

def validate_codename_characters
  return unless codename.to_s.match?(/[^a-z_]/)

  errors.add :codename, t(:core_error_codename_special_characters)
end

def validate_codename_permission
  return if Auth.always_ok? || Auth.as_id == creator_id

  errors.add :codename, t(:core_only_admins_codename)
end

def validate_codename_uniqueness
  return (self.codename = nil) if codename.blank?
  return if errors.present? || !Card.find_by_codename(codename)

  errors.add :codename, t(:core_error_code_in_use, codename: codename)
end

def validate_codename_simplicity
  return if name.simple?

  errors.add :codename, t(:core_codename_must_be_simple)
end