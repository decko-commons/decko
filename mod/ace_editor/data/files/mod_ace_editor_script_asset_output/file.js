// decko_ace_config.js.coffee
(function(){var e;decko.editors.add(".ace-editor-textarea",function(){return decko.initAce($(this))},function(){return e(this[0])}),$.extend(decko,{setAceConfig:function(e){var t;return t=function(){try{return $.parseJSON(e)}catch(t){return{}}},decko.aceConfig=t()},configAceEditor:function(e,t){var i;return i={showGutter:!0,theme:"ace/theme/github",printMargin:!1,tabSize:2,useSoftTabs:!0,maxLines:30,minLines:10},e.setOptions(i),e.session.setMode("ace/mode/"+t)},initAce:function(e){var t,i,n;(n=e.attr("data-ace-mode"))?(t=$("<div>",{position:"absolute",width:"auto",height:e.height()}).insertBefore(e),e.css("visibility","hidden"),e.css("height","0px"),(i=ace.edit(t[0])).getSession().setValue(e.val()),decko.configAceEditor(i,n),e.data("ace",i)):e.autosize()}}),e=function(e){var t;return t=$(e).siblings(".ace_editor"),ace.edit(t[0]).getSession().getValue()}}).call(this);