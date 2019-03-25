format :html do
  SIZE_IN_PX = { icon: 16, small: 75, medium: 200, large: 500 }.freeze

  # used to control size of svg
  view :max_size do
    if voo.size.is_a?(String) && voo.size.match(/^\d+x\d+\$/)
      max_size(*voo.size.split("x"))
    else
      px = SIZE_IN_PX[voo.size&.to_sym] || 200
      max_size px, px
    end
  end

  def max_size w, h
    "max-width: #{w}px; max-height: #{h}px"
  end
end
