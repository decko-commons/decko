# Hack to get rid of annoying parser warnings
module Parser
  def self.warn msg
    if msg.match? %r{^warning: (?:parser/current|[\d.]+-compliant syntax|please see)}
      return
    else
      super
    end
  end
end
