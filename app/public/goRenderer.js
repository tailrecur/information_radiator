(function ($) {
  Radiator.GoRenderer = function(monitor_id) {
    var self = {};
    self.monitor_id = monitor_id;
    self.pipelines = [];
    
    self.render = function(data) {
      _(data).each(function(pipeline) {
        self.pipelines.push(new Radiator.GoPipeline(pipeline));
      });
      screenDimension = Radiator.screen.getViewPortDimensions(self.monitor_id);
      sectionHeight = screenDimension.height / self.pipelines.length;
      var pipelineTop = 0;
      _(self.pipelines).each(function(pipeline) {
        dimension = new Radiator.ViewPortDimensions(0, pipelineTop, screenDimension.width, sectionHeight);
        pipeline.draw(dimension);
        pipelineTop += sectionHeight + 1;
      });
    }
  
    return {
      render: self.render,
    }
  }
  
  Radiator.BuildColor = (function() {
    var self = {};
    self.colors = [];
    self.colors["passed_sleeping"] = "green";
    self.colors["passed_building"] = "yellow";
    self.colors["failed_sleeping"] = "red";
    self.colors["failed_building"] = "#FF6103";
    
    return {
      evaluate: function(status, activity) {
        return self.colors[status + "_" + activity]
      }
    }
  })();
  
  Radiator.GoPipeline = function(data) {
    var self = {};
    self.data = data;
    self.draw = function(dimension) {
      Radiator.screen.renderer.rect(dimension.left, dimension.top, dimension.width, dimension.height, 0)
        .attr({
            'stroke-width': 4,
            stroke: 'red',
            fill: Radiator.BuildColor.evaluate(data.status, data.activity),
            zIndex: 0
        })
        .add();
      Radiator.screen.renderer.text(data.name, 100, dimension.top + dimension.height/2)
        .attr({zIndex: 1})
        .css({
            color: 'black',
            fontSize: '50px'
        })
        .add();
    };
    
    return {
      draw: self.draw,
    }
  }
})(jQuery);


