(function($) {
  Radiator.ScreenManager = function() {
    var self = {};
    self.monitors = [];
    
    self.width = $(window).width();
    self.height = $(window).height();
    
    self.addMonitor = function(id, cols, rows) {
      self.monitors.push([id, cols, rows]);
    }
    
    self.getViewPortDimensions = function(monitor_id) {
      return new Radiator.ViewPortDimensions(0,0,self.width, self.height);
    }
    
    self.renderer = new Highcharts.Renderer(
        $('#container')[0], 
        self.width,
        self.height
    );
    
    return {
      addMonitor: self.addMonitor,
      getViewPortDimensions: self.getViewPortDimensions,
      renderer: self.renderer,
    }
  };
  
  Radiator.ViewPortDimensions = function(left, top, width, height) {
    return {
      top: top,
      left: left,
      width: width,
      height: height,
    }
  };
  
  Radiator.Main = (function() {
    var self = {};
    self.monitors = [];
  
    self.startMonitors = function() {
      _(self.monitors).each(function(monitor){
        monitor.start();
      });
    }
  
    $(function () {
      Radiator.screen = new Radiator.ScreenManager();
      $.getJSON('/monitors', function(data) {
        _(data).each(function(monitor, index) {
          self.monitors.push(new Radiator.Monitor(monitor));
          Radiator.screen.addMonitor(index, 8, 8);
        });
        self.startMonitors();
      });
    });
  })();
  
})(jQuery);
