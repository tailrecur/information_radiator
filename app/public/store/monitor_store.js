(function ($) {
  Radiator.MonitorStore = (function() {
    var self = this;

    self.all = function(callback) {
      $.getJSON('/monitors', function(data) {
        callback(data);
      });
    }

    self.findById = function(id, callback) {
      $.getJSON('/monitors/' + id, function(data) {
        callback(data);
      });
    }

    return {
      all: all,
      findById: findById,
    }
  })();
})(jQuery);
