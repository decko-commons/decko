def upload_dir
  tmp_upload_dir
end

format :html do
  view :source, cache: :never do
    super()
  end

  view :core, cache: :never do
    super()
  end

  view :input, cache: :never do
    super()
  end
end
