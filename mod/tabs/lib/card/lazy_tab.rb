class Card
  # lazy-loading tabs. Tab panel content doesn't load until tab is visited.
  class LazyTab < Tab
    def url
      @url ||= (config_hash? && @config[:path]) || format.path(view: view)
    end

    def view
      @view ||= (config_hash? && @config[:view]) || @config
    end

    def tab_button
      if url
        super
      else
        wrap_with(:li, label, role: "presentation")
      end
    end

    def button_attrib
      @button_attrib ||= super.merge("data-url" => url.html_safe)
    end

    def tab_button_link
      add_class button_attrib, "load" unless active?
      super
    end

    def content
      @content ||= ""
    end

    def tab_pane args=nil, &block
      @content = yield if active? && block_given?
      super
    end
  end
end
