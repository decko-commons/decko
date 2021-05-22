class Card
  class Tab
    attr_reader :format, :name, :label, :content, :button_attrib

    class << self
      def tab_objects format, tab_hash, active_name, klass=nil
        klass ||= Card::Tab
        active_name ||= tab_hash.keys.first
        tab_hash.map do |name, config|
          klass.new format, name, active_name, config
        end
      end
    end

    delegate :add_class, :wrap_with, :unique_id, :link_to, to: :format

    def initialize format, name, active_name, config
      @format = format
      @name = name
      @active_name = active_name
      @config = config
    end

    def tab_button
      add_class button_attrib, "active" if active?
      wrap_with :li, tab_button_link,
                role: :presentation,
                class: "nav-item tab-li-#{name}"
    end

    def tab_pane args=nil
      pane_attr = { role: :tabpanel, id: tab_id }
      pane_attr.merge! args if args.present?
      add_class pane_attr, "tab-pane tab-pane-#{name}"
      add_class pane_attr, "active" if active?
      wrap_with :div, content, pane_attr
    end

    private

    def config_hash?
      @config.is_a? Hash
    end

    def label
      @label ||= (config_hash? && @config[:title]) || name
    end

    def content
      @content ||= config_hash? ? @config[:content] : @config
    end

    def button_attrib
      @button_attrib ||= (config_hash? && @config[:button_attr]) || {}
    end

    def tab_button_link
      add_class button_attrib, "nav-link"

      link_to label, button_attrib.merge(
        path: "##{tab_id}",
        role: "tab",
        "data-toggle" => "tab",
        "data-tab-name" => name
      )
    end

    def tab_id
      @tab_id ||= "#{unique_id}-#{name.to_name.safe_key}"
    end

    def active?
      name == @active_name
    end
  end
end
