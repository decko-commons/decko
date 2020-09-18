class Card
  class Format
    module Nesting
      # Handle the main nest
      module Main
        def wrap_main
          yield # no wrapping in base format
        end

        def main_nest opts
          wrap_main do
            main.rendered || main_nest_render(opts)
          end
        end

        def main_nest_render opts={}
          with_nest_mode :normal do
            if block_given?
              block.call
            else
              nest root.card, opts.merge(main_view: true, main: true)
            end
          end
        end

        def main_nest? nest_name
          nest_name == "_main" # && !root.already_mained?
        end

        def already_mained?
          return true if @main || @already_main

          @already_main = true
          false
        end

        def main!
          @main = true
        end

        # view=edit&items=closed
        def main_nest_options
          inherit(:main_opts) || {}
        end
      end
    end
  end
end
