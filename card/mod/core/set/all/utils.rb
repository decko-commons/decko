
def mod_path modname
  Cardio::Mod.dirs.path modname
end

delegate :t, to: ::I18n

format do
  delegate :t, to: ::I18n
  delegate :mod_path, to: :card
end
