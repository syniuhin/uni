var app = angular.module("classroom", ["ui.router", "ngCookies"]);

app.run(function(
  $http,
  $state,
  $rootScope,
  LoginService,
  StorageService,
  DataService
) {
  if (!StorageService.contains("defaults")) {
    DataService.loadDefaults($state, $http);
  }

  $rootScope.$on("$stateChangeStart", function(event, toState, toStateParams) {
    // track the state the user wants to go to;
    // authorization service needs this
    $rootScope.toState = toState;
    $rootScope.toStateParams = toStateParams;
    // if the principal is resolved, do an
    // authorization check immediately. otherwise,
    // it'll be done when the state it resolved.
    if (!LoginService.isAuthenticated()) {
      $state.go("login");
    }
  });
});

app.config([
  "$stateProvider",
  "$urlRouterProvider",
  function($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise("home");

    $stateProvider
      .state("site", {
        abstract: true,
        resolve: {
          authorize: [
            "LoginService",
            "$state",
            function(LoginService, $state) {
              if (!LoginService.isAuthenticated()) {
                $state.go("login");
              }
            }
          ]
        }
      })
      .state("wait", {
        url: "/wait/a/minute",
        template:
          '<iframe src="https://giphy.com/embed/k24uHda5UiIgw" width="480" height="270" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/pizza-travolta-saturday-night-fever-k24uHda5UiIgw">via GIPHY</a></p>'
      })
      .state("login", {
        parent: "site",
        url: "/login",
        templateUrl: "html/auth.html",
        controller: "AuthController"
      })
      .state("home", {
        parent: "site",
        url: "/home",
        templateUrl: "html/home.html",
        controller: "HomeController"
      })
      .state("journal", {
        parent: "site",
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
