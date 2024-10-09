// autocomplete.js.coffee
(function() {
  decko.slot.ready(function(slot) {
    return slot.find('._autocomplete').each(function(_i) {
      return decko.initAutoCardPlete($(this));
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
    var box, el;
    el = $('._search-box');
    box = new decko.searchBox(el);
    el.data("searchBox", box);
    return box.init();
  });

  decko.searchBox = (function() {
    function searchBox(el) {
      this.box = el;
      this.sourcepath = this.box.data("completepath");
      this.originalpath = this.sourcepath;
      this.config = {
        source: this.sourcepath,
        select: this.select
      };
    }

    searchBox.prototype.init = function() {
      return this.box.autocomplete(this.config, {
        html: true
      });
    };

    searchBox.prototype.select = function(_event, ui) {
      var url;
      url = ui.item.url;
      if (url) {
        return window.location = url;
      }
    };

    searchBox.prototype.form = function() {
      return this.box.closest("form");
    };

    searchBox.prototype.keyword = function() {
      return this.keywordBox().val();
    };

    searchBox.prototype.keywordBox = function() {
      return this.form().find("#query_keyword");
    };

    return searchBox;

  })();

}).call(this);
