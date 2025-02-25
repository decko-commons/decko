# Extending the base ruby object
class Object
  def to_name
    Cardname.new self
  end
end
