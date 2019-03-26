# class Card
#   class View
#     # method to render views with layouts
#     module Wrapper
#       def with_wrapper
#         if layout.present?
#           self.wrap ||= []
#           wrap.push layout.to_name.key
#         end
#
#         format.rendered = yield
#         return format.rendered unless wrap.present?
#
#         wrap.reverse_each do |wrapper|
#           format.rendered = render_wrapper wrapper
#         end
#         format.rendered
#       end
#
#       private
#
#       def render_wrapper wrapper
#         format.try("wrap_with_#{wrapper}") { format.rendered } ||
#           Card::Layout::CardLayout.new(wrapper, format).render
#       end
#     end
#   end
# end
#