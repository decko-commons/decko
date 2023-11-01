# represents an entry in admin.yml
class AdminItem
  attr_reader :mod, :category, :subcategory, :codename
  attr_accessor :roles

  def initialize mod, category, subcategory, codename
    @mod = mod
    @category = category
    @subcategory = subcategory
    @codename = codename
  end

  def title
    config_titles = Card::Set::All::Admin.basket[:config_title]
    if subcategory
      config_titles[subcategory.to_sym] || subcategory.capitalize
    else
      config_titles[category.to_sym] || category.capitalize
    end
  end
end
