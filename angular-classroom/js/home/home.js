app.controller("HomeController", [
  "$scope",
  "$state",
  "LoginService",
  "StorageService",
  function($scope, $state, LoginService, StorageService) {
    var me = this;

    me.getYears = function() {
      return StorageService.load("defaults").years.sort();
    };

    me.getSubjects = function() {
      return StorageService.load("defaults").subjects.sort();
    };

    me.getLessons = function() {
      return StorageService.load("defaults").lessons.sort();
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
      return Object.keys(entries[0]).map((name) => {
        return name[0].toUpperCase() + name.slice(1);
      })
    };
  }
]);
