include_set Abstract::SkinField

def virtual?
  new?
end

def raw_help_text
  <<-TEXT
    Override bootstrap [[https://github.com/twbs/bootstrap/blob/v5.1.3/scss/_variables.scss|variables]]
  TEXT
end
