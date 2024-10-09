// upload.js.coffee
(function() {
  var disableUploader;

  decko.editors.init[".file-upload"] = function() {
    return decko.upload_file(this);
  };

  $.extend(decko, {
    upload_file: function(fileupload) {
      var $_fileupload, url;
      $(fileupload).on('fileuploadsubmit', function(e, data) {
        var $_this, card_name, type_id;
        $_this = $(this);
        card_name = $_this.siblings(".attachment_card_name:first").attr("name");
        type_id = $_this.siblings("#attachment_type_id").val();
        return data.formData = {
          "card[type_id]": type_id,
          "attachment_upload": card_name
        };
      });
      $_fileupload = $(fileupload);
      if ($_fileupload.closest("form").attr("action").indexOf("update") > -1) {
        url = "card/update/" + $(fileupload).siblings("#file_card_name").val();
      } else {
        url = "card/create";
      }
      return $(fileupload).fileupload({
        url: decko.path(url),
        dataType: 'html',
        done: decko.doneFile,
        add: decko.chooseFile,
        progressall: decko.progressallFile
      });
    },
    chooseFile: function(e, data) {
      var editor;
      data.form.find('button[type=submit]').attr('disabled', true);
      editor = $(this).closest('.card-editor');
      $('#progress').show();
      editor.append('<input type="hidden" class="extra_upload_param" ' + 'value="true" name="attachment_upload">');
      editor.append('<input type="hidden" class="extra_upload_param" ' + 'value="preview_editor" name="view">');
      data.submit();
      editor.find('.choose-file').hide();
      return editor.find('.extra_upload_param').remove();
    },
    progressallFile: function(e, data) {
      var progress;
      progress = parseInt(data.loaded / data.total * 100, 10);
      return $('#progress .progress-bar').css('width', progress + '%');
    },
    doneFile: function(e, data) {
      var editor;
      editor = $(this).closest('.card-editor');
      editor.find('.chosen-file').replaceWith(data.result);
      return data.form.find('button[type=submit]').attr('disabled', false);
    }
  });

  $(window).ready(function() {
    $('body').on('click', '.cancel-upload', function() {
      var editor;
      editor = $(this).closest('.card-editor');
      editor.find('.choose-file').show();
      editor.find('.chosen-file').empty();
      editor.find('.progress').show();
      editor.find('#progress .progress-bar').css('width', '0%');
      return editor.find('#progress').hide();
    });
    $('body').on("submit", "form", function() {
      return disableUploader(this, true);
    });
    return $("body").on("ajax:complete", "form", function() {
      return disableUploader(this, false);
    });
  });

  disableUploader = function(form, toggle) {
    var uploader;
    uploader = $(form).find(".file-upload[type=file]");
    if (uploader[0]) {
      return uploader.prop("disabled", toggle);
    }
  };

}).call(this);
