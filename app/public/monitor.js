(function ($) {
  Radiator.Monitor = function(options) {
    var self = this;

    self.options = options;
    self.type = ko.observable("foo");
    self.pipelines = ko.observableArray();

    self.start_polling = function() {
      setInterval(function() {
        $.getJSON('/monitors/' + self.options.id, function(data) {
          _(data).each(function(pipeline) {
            _(self.pipelines()).each(function(existing_pipeline) {
              if(existing_pipeline.name() == pipeline.name) {
                existing_pipeline.refresh(pipeline);
              }
            });
          });
        });
      }, parseInt(self.options.refresh_rate) * 1000)
    };

    self.start = function() {
      $.getJSON('/monitors/' + self.options.id, function(data) {
        _(data).each(function(pipeline) {
          self.pipelines.push(new Radiator.Pipeline(pipeline));
        });
      });
      self.start_polling();
    };

    return {
      start: self.start,
      pipelines: self.pipelines,
    }
  };
})(jQuery);
