# Hack to get rid of annoying parser warnings
module Parser
  def self.warn msg
    return if msg =~ %r{^warning: (?:parser/current|[\d\.]+-compliant syntax|please see)}
    super
  end
end
