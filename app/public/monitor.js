(function ($) {
  Radiator.Monitor = function(options) {
    var self = {};
    
    self.options = options;
    self.renderer = Radiator.RendererFactory.create(options.type, options.id);
    
    self.start = function() {
      setInterval(function() {
        $.getJSON('/monitors/' + self.options.id, function(data) {
          self.renderer.render(data);
        });
      }, parseInt(options.refresh_rate) * 1000)
    };
    
    return {
      start: self.start,
    }
  };
})(jQuery);

Radiator.RendererFactory = (function() {
  var self = {};
  self.create = function(type, monitor_id) {
    if(type == "go") {
      return new Radiator.GoRenderer(monitor_id);
    }
  }
  
  return {
    create: self.create,
  }
})();