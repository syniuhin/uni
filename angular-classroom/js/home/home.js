app.controller("HomeController", [
  "$scope",
  "$state",
  "LoginService",
  "StorageService",
  function($scope, $state, LoginService, StorageService) {
    var me = this;

    me.getYears = function() {
      return StorageService.load("defaults")
        .years.concat(StorageService.loadOr("data_points_year", []))
        .sort();
    };

    me.getSubjects = function() {
      return StorageService.load("defaults")
        .subjects.concat(StorageService.loadOr("data_points_subject", []))
        .sort();
    };

    me.getLessons = function() {
      return StorageService.load("defaults")
        .lessons.concat(StorageService.loadOr("data_points_lesson", []))
        .sort();
    };

    me.logout = function() {
      LoginService.logout();
      $state.transitionTo("login");
    };

    me.createNewEntry = function(entry) {
      StorageService.createOrUpdate("entries", [entry], existing => {
        existing.push(entry);
        return existing;
      });
    };

    me.listEntries = function() {
      return StorageService.loadOr("entries", []);
    };

    me.entryStructure = function() {
      var entries = StorageService.load("entries");
      if (entries === undefined || entries.length === 0) {
        return [];
      }
      var keys = Object.keys(entries[0]);
      // Cut $$hashKey
      return keys.slice(0, keys.length - 1).map(name => {
        return name[0].toUpperCase() + name.slice(1);
      });
    };

    me.validDataPoint = function(data_point) {
      if (data_point === undefined) {
        return false;
      }
      var key = Object.keys(data_point)[0];
      var keys = `${key}s`;
      return (
        data_point[key] !== undefined &&
        !StorageService.load("defaults")[keys].includes(data_point[key]) &&
        !me._dataPointExists(key, data_point[key])
      );
    };

    me._dataPointExists = function(key, value) {
      var data_points = StorageService.loadOr(`data_points_${key}`, []);
      var keys = `${key}s`;
      return data_points.includes(value);
    };

    me.createNewDataPoint = function(data_point) {
      var key = Object.keys(data_point)[0];
      var value = data_point[key];
      StorageService.createOrUpdate(`data_points_${key}`, [value], existing => {
        existing.push(value);
        return existing;
      });
      delete data_point[key];
    };
  }
]);
