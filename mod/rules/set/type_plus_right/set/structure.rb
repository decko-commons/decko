format :html do
  def nest_snippet
    @nest_snippet ||=
      begin
        super
        @nest_snippet.field! if @nest_snippet.empty?
        @nest_snippet
      end
  end
end
