include_set Abstract::CodeFile

def source_files
  #%w[lib/javascript/script_jquery.js lib/javascript/jquery_ujs.js]
  ["vendor/jquery_rails/vendor/assets/javascripts/jquery3.js",
   "vendor/jquery_rails/vendor/assets/javascripts/jquery_ujs.js"]
end

def source_dir
  ""
end
