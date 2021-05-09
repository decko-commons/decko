# -*- encoding : utf-8 -*-

class Card
  class Content
    class Diff
      class << self
        def complete a, b, opts={}
          Card::Content::Diff.new(a, b, opts).complete
        end

        def summary a, b, opts={}
          Card::Content::Diff.new(a, b, opts).summary
        end

        def render_added_chunk text
          "<ins class='diffins diff-added'>#{text}</ins>"
        end

        def render_deleted_chunk text, _count=true
          "<del class='diffdel diff-deleted'>#{text}</del>"
        end
      end

      attr_reader :result

      delegate :summary, :complete, :summary_omits_content?, to: :result

      # diff options
      # :format  => :html|:text|:pointer|:raw
      #   :html    = maintain html structure, but compare only content
      #   :text    = remove all html tags; compare plain text
      #   :pointer = remove all double square brackets
      #   :raw     = escape html tags and compare everything
      #
      # summary: {length: <number> , joint: <string> }
      def initialize old_version, new_version, opts={}
        @result = Result.new opts[:summary]
        return unless new_version

        lcs_opts = lcs_opts_for_format opts[:diff_format]
        LCS.new(lcs_opts).run(old_version, new_version, @result)
      end

      def red?
        @result.dels_cnt.positive?
      end

      def green?
        @result.adds_cnt.positive?
      end

      private

      def lcs_opts_for_format diff_format
        opts = {}
        case diff_format
        when :html
          opts[:exclude] = /^</
        when :text
          opts[:reject] =  /^</
          opts[:postprocess] = proc { |word| word.gsub("\n", "<br>") }
        when :pointer
          opts[:preprocess] = proc { |word| word.gsub("[[", "").gsub("]]", "<br>") }
        else # :raw
          opts[:preprocess] = proc { |word| CGI.escapeHTML(word) }
        end
        opts
      end
    end
  end
end
