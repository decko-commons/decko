def write_at fname, at_line, sdat
  open(fname, "r+") do |f|
    (at_line - 1).times do # read up to the line you want to write after
      f.readline
    end
    pos = f.pos # save your position in the file
    rest = f.read # save the rest of the file
    f.seek pos # go back to the old position
    f.puts sdat # write new data & rest of file
    f.puts rest
    color_puts "created", :green, fname
  end
end

def write_to_mod rel_dir, filename
  dir = File.join "mod", @mod, content_dir
  path = File.join dir, filename
  Dir.mkdir(dir) unless Dir.exist?(dir)
  if File.exist?(path)
    color_puts "file exists", :yellow, path
  else
    File.open(path, "w") do |opened_file|
      yield(opened_file)
      color_puts "created", :green, path
    end
  end
end