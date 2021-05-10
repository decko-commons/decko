# Hack to get rid of annoying parser warnings
module Parser
  def self.warn msg
    super unless msg.match?(
      %r{^warning: (?:parser/current|[\d.]+-compliant syntax|please see)}
    )
  end
end
