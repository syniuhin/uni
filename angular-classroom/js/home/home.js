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

    me.saved = [];
    me.createNewEntry = function(entry) {
      me.saved.push(entry);
    };
  }
]);
