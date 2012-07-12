Radiator.Pipeline = function(options) {
  var self = this;
  
  var buildColors = {
    passed_sleeping: "green",
    passed_building: "yellow",
    failed_sleeping: "red",
    failed_building: "#FF6103",
  }

  self.name = ko.observable(options.name);
  self.status = ko.observable(options.status);
  self.activity = ko.observable(options.activity);
  self.displayName = ko.computed(function() {
     return self.name().replace(/_/g," ");
  });

  self.buildStatus = ko.computed(function() {
     return self.status() + "-" + self.activity();
  });

  self.refresh = function(data) {
    self.status(data.status);
    self.activity(data.activity);
  };
  
  return self;
};
