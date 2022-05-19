format :html do
  view :views_by_format do
    accordion do
      views_by_format_hash.each_with_object([]) do |(format, views), array|
        array << accordion_item(format, body: list_group(views))
      end
    end
  end

  view :views_by_name do
    views = methods.map do |method|
      Regexp.last_match(1) if method.to_s.match?(/^_view_(.+)$/)
    end.compact.sort
    list_group views
  end

  private

  def views_by_format_hash
    self.class.ancestors.each_with_object({}) do |format_class, hash|
      next unless (views = views_for_format_class format_class).present?

      format_class.name =~ /^Card(::Set)?::(.+?)$/ #::(\w+Format)
      hash[Regexp.last_match(2)] = views
    end
  end

  def views_for_format_class format_class
    format_class.instance_methods.map do |method|
      next unless method.to_s =~ /^_view_(.+)$/

      Regexp.last_match(1)
    end.compact
  end
end
