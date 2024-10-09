// decko_ace_config.js.coffee
(function() {
  var aceEditorContent;

  decko.editors.add('.ace-editor-textarea', function() {
    return decko.initAce($(this));
  }, function() {
    return aceEditorContent(this[0]);
  });

  $.extend(decko, {
    setAceConfig: function(string) {
      var setter;
      setter = function() {
        try {
          return $.parseJSON(string);
        } catch (error) {
          return {};
        }
      };
      return decko.aceConfig = setter();
    },
    configAceEditor: function(editor, mode) {
      var conf;
      conf = {
        showGutter: true,
        theme: "ace/theme/github",
        printMargin: false,
        tabSize: 2,
        useSoftTabs: true,
        maxLines: 30,
        minLines: 10
      };
      editor.setOptions(conf);
      return editor.session.setMode("ace/mode/" + mode);
    },
    initAce: function(textarea) {
      var editDiv, editor, mode;
      mode = textarea.attr("data-ace-mode");
      if (!mode) {
        textarea.autosize();
        return;
      }
      editDiv = $("<div>", {
        position: "absolute",
        width: "auto",
        height: textarea.height()
      }).insertBefore(textarea);
      textarea.css("visibility", "hidden");
      textarea.css("height", "0px");
      editor = ace.edit(editDiv[0]);
      editor.getSession().setValue(textarea.val());
      decko.configAceEditor(editor, mode);
      textarea.data("ace", editor);
    }
  });

  aceEditorContent = function(element) {
    var ace_div, editor;
    ace_div = $(element).siblings(".ace_editor");
    editor = ace.edit(ace_div[0]);
    return editor.getSession().getValue();
  };

}).call(this);
