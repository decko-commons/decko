basket[:tasks][:delete_upload_tmp_files] = {
  mod: :carrierwave,
  execute_policy: -> { Card.delete_tmp_files_of_cached_uploads }
}

  # { name: :move_files,
  #   mod: :carrierwave,
  #   execute_policy: -> { Card.update_all_storage_locations } },

