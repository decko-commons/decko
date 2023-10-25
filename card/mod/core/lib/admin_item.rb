class AdminItem
  # represents an entry in admin.yml
  attr_reader :mod, :category, :subcategory, :codename, :roles
  def initialize mod, category, subcategory, codename, roles
    @mod = mod
    @category = category
    @subcategory = subcategory
    @codename = codename
    @roles = roles
  end

  def title
    config_titles = Card::Set::All::Admin.basket[:config_title]
    subcategory ?
      config_titles[subcategory.to_sym] || subcategory.capitalize :
      config_titles[category.to_sym]  || category.capitalize
  end
end
