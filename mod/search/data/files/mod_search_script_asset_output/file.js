// autocomplete.js.coffee
(function(){decko.slotReady(function(t){return t.find("_autocomplete").each(function(){return decko.initAutoCardPlete($(this))})}),$.extend(decko,{initAutoCardPlete:function(t){var e,o;if(e=t.data("options-card"))return o=e+".json?view=name_match",t.autocomplete({source:decko.slotPath(o)})}})}).call(this);