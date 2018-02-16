# -*- encoding : utf-8 -*-

class UpdateTinymceConfig < Card::Migration::Core
  TINYMCE_CONF = <<-JSON.strip_heredoc
    {
      "theme": "modern",
      "menubar": "edit view insert format table",
      "plugins": "autoresize code lists hr link autolink table contextmenu textcolor colorpicker",
      "toolbar1": "formatselect | bold italic strikethrough forecolor backcolor | link | alignleft aligncenter alignright alignjustify  | numlist bullist outdent indent  | removeformat",
      "width":"100%",
      "auto_resize":true,
      "autoresize_max_height": 500,
      "relative_urls":false,
      "extended_valid_elements":"a[name|href|target|title|onclick],img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],hr[class|width|size|noshade],font[face|size|color|style],span[class|align|style]"
     }
  JSON

  def up
    ensure_card :tiny_mce,
                content: TINYMCE_CONF
  end
end
