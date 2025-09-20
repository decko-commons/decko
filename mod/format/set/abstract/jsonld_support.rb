module Card::Set::Abstract::JsonldSupported
  extend Card::Set
    format :jsonld do
      def jsonld_supported? = true

      def license_url metric
        dir = metric.license.gsub(/(CC|4.0)/, "").strip.downcase
        "https://creativecommons.org/licenses/#{dir}/4.0/"
      end

      # Sanitizer that strips all html tags
      def sanitize_html(value)
        return if value.blank?
        (@full_sanitizer ||= Rails::Html::FullSanitizer.new).sanitize(value.to_s).presence
      end

      def context
        "#{request.base_url}/context/#{card.type}.jsonld"
      end
    end

    def export_formats
      %i[csv json jsonld]
    end
end
