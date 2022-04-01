#! no set module
class FollowLink
  attr_reader :format, :rule_content, :link_text, :action, :css_class, :hover_text

  delegate :link_to, to: :format

  def initialize format
    @format = format
    @card = format.card
  end

  def modal_link icon=false
    opts = link_opts.merge(
      "data-path": link_opts[:path],
      "data-bs-toggle": "modal",
      "data-bs-target": "#modal-#{card.name.safe_key}",
      class: css_classes("follow-link", link_opts[:class])
    )
    link_to render_link_text(icon), opts
  end

  def button
    opts = link_opts(:follow_section).merge(
      remote: true,
      class: @format.css_classes("follow-link", link_opts[:class],
                                 "slotter btn btn-sm btn-primary")
    )
    opts["data-update-foreign-slot"] =
      ".d0-card-body > .card-slot.RIGHT-Xfollower.content-view"
    opts["data-hover-text"] = hover_text if hover_text
    link_to render_link_text, opts
  end

  def link_opts success_view=:follow_status
    { title: title,
      path: path(success_view),
      class: css_class }
  end

  def render_link_text icon=false
    verb = %(<span class="follow-verb">#{link_text}</span>)
    icon = icon ? icon_tag(:flag) : ""
    [icon, verb].compact.join.html_safe
  end

  private

  def mark
    @card.follow_set_card.follow_rule_name Auth.current.name
  end

  def path view=:follow_status
    @format.path mark: mark,
                 action: :update,
                 success: { mark: @card.name, view: view },
                 card: { content: "[[#{rule_content}]]" }
  end

  def title
    "#{action} emails about changes to #{@card.follow_label}"
  end
end
