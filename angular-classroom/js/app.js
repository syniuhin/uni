var app = angular.module("classroom", ["ui.router", "ngCookies"]);

app.run(function($rootScope, $location, $state, LoginService, StorageService) {
  $rootScope.$on("$stateChangeStart", function(
    event,
    toState,
    toParams,
    fromState,
    fromParams
  ) {
    console.log("Changed state to: " + toState);
  });

  if (!LoginService.isAuthenticated()) {
    $state.transitionTo("login");
  } else {
    // Initialize defaults
    if (!StorageService.contains("defaults")) {
      StorageService.save("defaults", {
        years: ["9A", "10B", "11A"],
        subjects: ["Math", "History", "Physics"],
        lessons: ["01/12, 4", "02/12, 1"]
      });
    }
  }
});

app.config([
  "$stateProvider",
  "$urlRouterProvider",
  function($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise("home");

    $stateProvider
      .state("login", {
        url: "/login",
        templateUrl: "./html/auth.html",
        controller: "AuthController"
      })
      .state("home", {
        url: "/home",
        templateUrl: "./html/home.html",
        controller: "HomeController"
      });
  }
]);
