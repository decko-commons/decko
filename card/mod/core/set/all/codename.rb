def codename
  super&.to_sym
end

event :validate_codename, :validate, on: :update, changed: :codename do
  validate_codename_permission
  validate_codename_uniqueness
end

event :reset_codename_cache, :integrate, changed: :codename do
  Card::Codename.reset_cache
end

private

def validate_codename_permission
  return if Auth.always_ok?
  errors.add :codename, "only admins can set codename"
end

def validate_codename_uniqueness
  return (self.codename = nil) if codename.blank?
  return if errors.present? || !Card.find_by_codename(codename)
  errors.add :codename, "codename #{codename} already in use"
end
