(function($) {
  Radiator.Screen = function() {
    var self = this;
    
    self.monitors = ko.observableArray();    
    
    self.display = function() {
      $.getJSON('/monitors', function(data) {
        _(data).each(function(monitorData, index) {
          var monitor = new Radiator.Monitor(monitorData);
          self.monitors.push(monitor);
          monitor.start();
        });
      });
    }

    return self;
  };
  
})(jQuery);
jQuery(function() {
  screen = new Radiator.Screen();
  ko.applyBindings(screen, $('#screen')[0]);
  screen.display();
});
