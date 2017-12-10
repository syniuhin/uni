app.controller("HomeController", [
  "$scope",
  "$state",
  "StorageService",
  "DataService",
  function($scope, $state, StorageService, DataService) {
    var me = this;

    me.getYears = function() {
      return DataService.getYears();
    };

    me.getSubjects = function() {
      return DataService.getSubjects();
    };

    me.getLessons = function() {
      return DataService.getLessons();
    };

    me.isEntryValid = function(entry) {
      return (
        entry !== undefined &&
        entry.hasOwnProperty("year") &&
        entry.hasOwnProperty("subject") &&
        entry.hasOwnProperty("lesson") &&
        !me
          .listEntries()
          .find(
            e =>
              e.year === entry.year &&
              e.subject === entry.subject &&
              e.lesson === entry.lesson
          )
      );
    };

    me.isEntryInvalid = function(entry) {
      return !me.isEntryValid(entry);
    };

    me.createNewEntry = function(entry) {
      DataService.createNewEntry(entry);
    };

    me.listEntries = function() {
      return DataService.getEntries();
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

    me.isDataPointValid = function(data_point) {
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

    me.goToJournal = function(entry) {
      $state.transitionTo("journal", {
        year: entry.year,
        subject: entry.subject,
        lesson: entry.lesson
      });
    };
  }
]);
