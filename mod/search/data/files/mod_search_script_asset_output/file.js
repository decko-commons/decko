// autocomplete.js.coffee
(function(){decko.slot.ready(function(e){return e.find("._autocomplete").each(function(){return decko.initAutoCardPlete($(this))}),e.find("._select2autocomplete").each(function(){return decko.initSelect2Autocomplete($(this),"complete")})}),$.extend(decko,{initSelect2Autocomplete:function(e,t,n,o,l,c){var a;return null==n&&(n=decko.autocompletePrepareItems),null==o&&(o=decko.autocompleteTemplateResult),null==l&&(l=decko.autocompleteTemplateSelection),null==c&&(c={}),a={placeholder:e.attr("placeholder"),escapeMarkup:function(e){return e},minimumInputLength:0,maximumSelectionSize:1,ajax:{delay:200,url:decko.path(":search.json"),data:function(e){return{query:{keyword:e.term},view:t}},processResults:function(e){return{results:n(e)}},cache:!0},templateResult:o,templateSelection:l,multiple:!1,width:"100%!important"},$.extend(a,c),e.select2(a)},autocompleteTemplateResult:function(e){return e.loading?e.text:'<span class="search-box-item-value ml-1">'+e.text+"</span>"},autocompleteTemplateSelection:function(e){return'<span class="search-box-item-value ml-1">'+e.text+"</span>"},autocompletePrepareItems:function(e){var t;return t=[],$.each(e.result,function(e,n){return t.push({id:n[0],text:n[0]})}),t},initAutoCardPlete:function(e){var t,n;if(t=e.data("options-card"))return n=t+".json?view=name_match",e.autocomplete({source:decko.slot.path(n)})}})}).call(this);
// search_box.js.coffee
(function(){var e,t,a,r,n;$(window).ready(function(){var a;return a=$("._search-box"),decko.initSelect2Autocomplete(a,"search_box_complete",n,e,t,{minimumInputLength:1,multiple:!0,containerCssClass:"select2-search-box-autocomplete",dropdownCssClass:"select2-search-box-dropdown",width:"100%!important"}),a.on("select2:select",function(e){return r(e)})}),e=function(e){return e.loading?e.text:'<i class="material-icons">'+e.icon+'</i><span class="search-box-item-label">'+e.prefix+':</span> <span class="search-box-item-value">'+e.label+"</span>"},t=function(e){return e.icon?'<i class="material-icons">'+e.icon+'</i><span class="search-box-item-value">'+e.label+"</span>":e.text},n=function(e){var t,r;return t=[],r=e.term,e.search&&t.push(a({prefix:"search",id:r,text:r})),$.each(["add","new"],function(r,n){var i;if(i=e[n])return t.push(a({prefix:n,icon:"add",text:i[0],href:i[1]}))}),$.each(e.goto,function(e,r){var n;return n=a({prefix:"go to",id:e,icon:"arrow_forward",text:r[0],href:r[1],label:r[2]}),t.push(n)}),t},a=function(e){return e.id||(e.id=e.prefix),e.icon||(e.icon=e.prefix),e.label||(e.label='<strong class="highlight">'+e.text+"</strong>"),e},r=function(e){var t;return(t=e.params.data).href?window.location=decko.path(t.href):$(e.target).closest("form").submit(),$(e.target).attr("disabled","disabled")}}).call(this);