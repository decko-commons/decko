MOD_FILE_DIR = "data/files".freeze

event :uncode_attachment_storage, :initialize, on: :update, when: :uncode? do
  @storage_type = storage_type_from_config unless @explicit_storage_type
end

event :validate_coded_storage_type, :validate, on: :save, when: :coded? do
  storage_type_error :mod_argument_needed_to_save unless mod
  storage_type_error :codename_needed_for_storage if codename.blank?
end

def mod= value
  @mod = value.to_s
end

def mod
  @mod ||= coded? && mod_from_content
end

private

def uncode?
  (@explicit_storage_type != :coded) && !set_specific[:mod].present? && current.coded?
end

def storage_type_error error_name
  errors.add :storage_type, t("carrierwave_#{error_name}")
end

def mod_from_content
  if (m = content.match %r{^:[^/]+/([^.]+)})
    m[1] # current mod_file format
  else
    mod_from_deprecated_content
  end
end

# place for files of mod file cards
def coded_dir new_mod=nil
  dir = File.join mod_dir(new_mod), MOD_FILE_DIR, codename.to_s
  FileUtils.mkdir_p(dir) unless File.directory?(dir)
  dir
end

def mod_dir new_mod=nil
  mod_name = new_mod || mod
  dir = Cardio::Mod.dirs.path(mod_name) || (mod_name.to_sym == :test && "test")

  raise Error, "can't find mod \"#{mod_name}\"" unless dir

  dir
end

def deprecated_mod_file?
  content.present? && !content.match?(/^~/) && content.split("\n")&.size == 4
end

# old format is still used in card_changes
def mod_from_deprecated_content
  content.split("\n").last if deprecated_mod_file?
end
