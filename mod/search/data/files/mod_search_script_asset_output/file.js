// autocomplete.js.coffee
(function() {
  decko.slot.ready(function(slot) {
    slot.find('._autocomplete').each(function(_i) {
      return decko.initAutoCardPlete($(this));
    });
    return slot.find('._select2autocomplete').each(function(_i) {
      return decko.select2Autocomplete.init($(this));
    });
  });

  decko.initAutoCardPlete = function(input) {
    var optionsCard, path;
    optionsCard = input.data('options-card');
    if (!optionsCard) {
      return;
    }
    path = optionsCard + '.json?view=name_match';
    return input.autocomplete({
      source: decko.slot.path(path)
    });
  };

  decko.select2Autocomplete = {
    init: function(el, options, ajaxOptions) {
      var opts;
      opts = $.extend({}, this._defaults(el), options);
      if (ajaxOptions) {
        $.extend(opts.ajax, ajaxOptions);
      }
      return el.select2(opts);
    },
    _defaults: function(el) {
      return {
        multiple: false,
        width: "100%!important",
        minimumInputLength: 0,
        maximumSelectionSize: 1,
        placeholder: el.attr("placeholder"),
        escapeMarkup: function(markup) {
          return markup;
        },
        ajax: {
          delay: 200,
          cache: true,
          url: decko.path(':search.json'),
          processResults: function(data) {
            return {
              results: data
            };
          },
          data: function(params) {
            return {
              query: {
                keyword: params.term
              },
              view: "complete"
            };
          }
        }
      };
    }
  };

}).call(this);

// search_box.js.coffee
(function() {
  $(window).ready(function() {
    var searchBox;
    searchBox = $('._search-box');
    if (searchBox.length > 0) {
      decko.searchBox.init(searchBox);
      return searchBox.on("select2:select", function(e) {
        return decko.searchBox.select(e);
      });
    }
  });

  decko.searchBox = {
    init: function(el) {
      return decko.select2Autocomplete.init(el, this._options(), {
        data: function(pobj) {
          var params;
          params = {
            query: {
              keyword: pobj.term
            },
            view: "search_box_complete"
          };
          el.closest("form").serializeArray().map(function(p) {
            if (p.name !== "query[keyword]") {
              return params[p.name] = p.value;
            }
          });
          return params;
        }
      });
    },
    select: function(event) {
      var form, href;
      href = this._eventHref(event);
      form = $(event.target).closest("form");
      if (href) {
        return window.location = decko.path(href);
      } else {
        return form.submit();
      }
    },
    _eventHref: function(event) {
      var d, p;
      p = event.params;
      d = p && p.data;
      return d && d.href;
    },
    _options: function(_el) {
      return {
        minimumInputLength: 1,
        containerCssClass: 'select2-search-box-autocomplete',
        dropdownCssClass: 'select2-search-box-dropdown',
        allowClear: true,
        width: "100%"
      };
    }
  };

}).call(this);
