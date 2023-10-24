class AdminItem
  attr_reader :name, :category, :subcategory
  def initialize name, mod, category, subcategory
    @name = name
    @mod = mod
    @category = category
    @subcategory = subcategory
  end
end