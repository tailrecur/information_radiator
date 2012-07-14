(function($) {
  Radiator.Screen = function() {
    var self = this;
    
    self.errorMessage = ko.observable();
    self.monitors = ko.observableArray();    
    
    self.showError = function(data) {
      self.errorMessage(data.message);
    }
    
    self.clearError = function() {
      self.errorMessage("");
    }
    
    self.display = function() {
      Radiator.MonitorStore.all(function(data) {
        _(data).each(function(monitorData, index) {
          var monitor = new Radiator.Monitor(monitorData);
          self.monitors.push(monitor);
          monitor.start();
        });
      }, self.showError);
    }

    return self;
  };
  
})(jQuery);
jQuery(function() {
  screen = new Radiator.Screen();
  ko.applyBindings(screen, $('#screen')[0]);
  $("#container").ajaxError(function(e, jqxhr, settings, exception) {
    console.log("ajaxError");
  });
  screen.display();
});
