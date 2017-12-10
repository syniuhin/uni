var app = angular.module("classroom", ["ui.router", "ngCookies"]);

app.run(function($http, $state, LoginService, StorageService, DataService) {
  if (!StorageService.contains("defaults")) {
    DataService.loadDefaults($state, $http);
  } else if (!LoginService.isAuthenticated()) {
    $state.transitionTo("login");
  }
});

app.config([
  "$stateProvider",
  "$urlRouterProvider",
  function($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise("home");

    $stateProvider
      .state("wait", {
        url: "/wait/a/minute",
        template:
          '<iframe src="https://giphy.com/embed/k24uHda5UiIgw" width="480" height="270" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/pizza-travolta-saturday-night-fever-k24uHda5UiIgw">via GIPHY</a></p>'
      })
      .state("login", {
        url: "/login",
        templateUrl: "html/auth.html",
        controller: "AuthController"
      })
      .state("home", {
        url: "/home",
        templateUrl: "html/home.html",
        controller: "HomeController"
      })
      .state("journal", {
        url: "/journal/:year/:subject/:lesson",
        component: "journal",
        resolve: {
          data: function($transition$) {
            var params = $transition$.params();
            return Promise.resolve({
              year: params.year,
              subject: params.subject,
              lesson: params.lesson
            });
          }
        }
      });
  }
]);
