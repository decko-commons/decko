class Card
  # generates pagination links
  class PagingLinks
    MAX_PAGES = 100

    def initialize total_pages, current_page
      @total = total_pages
      @current = current_page
    end

    # @param window [integer] number of page links shown left and right
    #   of the current page
    # @example: current page = 5, window = 2
    #   |<<|1|...|3|4|[5]|6|7|...|10|>>|
    # @yield [text, page, status, options] block to build single paging link
    # @yieldparam status [Symbol] :active (for current page) or :disabled
    # @yieldparam page [Integer] page number, first page is 0
    # @return [Array<String>]
    def build window=2, &block
      @render_item = block
      links window
    end

    private

    def links window
      @window_start = [@current - window, 0].max
      @window_end = [@current + window, @total].min
      left_part + window_part + right_part
    end

    # the links around the current page
    def window_part
      (@window_start..@window_end).map do |page|
        direct_page_link page
      end.compact
    end

    def left_part
      [
        previous_page_link,
        (direct_page_link 0 if @window_start.positive?),
        (ellipse if @window_start > 1)
      ].compact
    end

    def right_part
      parts = [next_page_link]
      parts.unshift direct_page_link(@total) if add_final_page?
      parts.unshift ellipse if @total > @window_end + 1
      parts
    end

    def add_final_page?
      @total <= MAX_PAGES && @total > @window_end
    end

    def previous_page_link
      paging_item '<span aria-hidden="true">&laquo;</span>', previous_page,
                  "aria-label" => "Previous", status: :previous
    end

    def next_page_link
      paging_item '<span aria-hidden="true">&raquo;</span>', next_page,
                  "aria-label" => "Next", status: :next
    end

    def direct_page_link page
      return unless page >= 0 && page <= @total

      paging_item page + 1, page
    end

    def ellipse
      paging_item "<span>...</span>", nil, status: :ellipses
    end

    def paging_item text, page, options={}
      status =
        if page == @current
          :current
        else
          options.delete :status
        end
      @render_item.call text, page, status, options
    end

    def previous_page
      @current.positive? ? @current - 1 : false
    end

    def next_page
      @current < @total ? @current + 1 : false
    end
  end
end
