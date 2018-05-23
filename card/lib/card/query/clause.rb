
module Card::Query::Clause
  #    attr_accessor :clause

  def safe_sql txt
    txt = txt.to_s
    txt =~ /[^\w\*\(\)\s\.\,]/ ? raise("WQL contains disallowed characters: #{txt}") : txt
  end

  def quote v
    connection.quote(v)
  end

  def connection
    @connection ||= ActiveRecord::Base.connection
  end
end
