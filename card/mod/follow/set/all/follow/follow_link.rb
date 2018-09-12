#! no set module
class FollowLink
  cattr_accessor :rule_content, :link_text, :action, :css_class, :hover_text
  def initialize format
    @format = format
    @card = format.card
  end

  def modal_link icon=false
    opts = link_opts.merge(
      "data-path": link_opts[:path],
      "data-toggle": "modal",
      "data-target": "#modal-#{card.name.safe_key}",
      class: css_classes("follow-link", link_opts[:class]))
    format.link_to render_link_text(icon), opts
  end

  def bridge_link
    opts = link_opts.merge(
      remote: true,
      class: css_classes("follow-link", opts[:class], "slotter btn btn-primary")
    )
    opts["data-hover-text"] = @hover_text if @hover_text
    opts[:path][:success][:view] = :follow_section
    link_to render_link_text, opts
  end

  def link_opts
    { content: @rule_content,
      title: title,
      verb: @link_text,
      path: path,
      class: @css_class }
  end

  def render_link_text icon=false
    verb = %(<span class="follow-verb">#{@link_text}<span>)
    icon = icon ? icon_tag(:flag) : ""
    [icon, verb].compact.join.html_safe
  end


  private

  def mark
    @card.follow_set_card.follow_rule_name Auth.current.name
  end

  def path view=:follow_status
    format.path mark: mark,
                action: :update,
                success: { view: :follow_status },
                card: { content: "[[#{@rule_content}]]" }
  end

  def title
    "#{@action} emails about changes to #{@card.follow_label}"
  end
end


class StartFollowLink < FollowLink
  @rule_content = "*never"
  @link_text = "follow"
  @action = "send"
  @css_class = "follow-toggle-on"
end

class StopFollowLink < FollowLink
  @rule_content = "*always"
  @link_text = "following"
  @hover_text = "unfollow"
  @action = "stop sending"
  @css_class = "follow-toggle-off"
end
