def no_upload?
  web? || storage_type_from_config == :web
end
