Radiator.Pipeline = function(options) {
  var self = this;
  
  self.name = ko.observable(options.name);
  self.status = ko.observable(options.status);
  self.activity = ko.observable(options.activity);
  self.buildBreakers = ko.observableArray(options.buildBreakers);
  self.displayName = ko.computed(function() {
     return self.name().replace(/_/g," ");
  });
  self.buildStatus = ko.computed(function() {
     return self.status() + "-" + self.activity();
  });
  self.failed = ko.computed(function() {
    return self.status() == "failed";
  });

  self.refresh = function(data) {
    self.status(data.status);
    self.activity(data.activity);
  };
  
  return self;
};
