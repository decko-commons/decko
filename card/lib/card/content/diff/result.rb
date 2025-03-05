class Card
  class Content
    class Diff
      # Result object for Diff processing
      class Result
        attr_accessor :complete, :dels_cnt, :adds_cnt
        attr_writer :summary

        def initialize summary_opts=nil
          @dels_cnt = 0
          @adds_cnt = 0
          @complete = ""
          @summary = Summary.new summary_opts
        end

        def summary
          @summary.rendered
        end

        def summary_omits_content?
          @summary.omits_content?
        end

        def write_added_chunk text
          @adds_cnt += 1
          @complete << Diff.render_added_chunk(text)
          @summary.add text
        end

        def write_deleted_chunk text
          @dels_cnt += 1
          @complete << Diff.render_deleted_chunk(text)
          @summary.delete text
        end

        def write_unchanged_chunk text
          @complete << text
          @summary.omit
        end

        def write_excluded_chunk text
          @complete << text
        end
      end
    end
  end
end
