
event :update_public_link_on_create, :integrate, on: :create, when: :local? do
  update_public_link
end

event :remove_public_link_on_delete, :integrate, on: :delete, when: :local? do
  remove_public_links
end

event :update_public_link, after: :update_read_rule, when: :local? do
  return if content.blank?
  if who_can(:read).include? Card::AnyoneID
    create_public_links
  else
    remove_public_links
  end
end

private

def create_public_links
  path = attachment.public_path
  return if File.exist? path
  FileUtils.mkdir_p File.dirname(path)
  File.symlink attachment.path, path unless File.symlink? path
  create_versions_public_links
end

def create_versions_public_links
  attachment.versions.each_value do |version|
    next if File.symlink? version.public_path
    File.symlink version.path, version.public_path
  end
end

def remove_public_links
  symlink_dir = File.dirname attachment.public_path
  return unless Dir.exist? symlink_dir
  FileUtils.rm_rf symlink_dir
end
