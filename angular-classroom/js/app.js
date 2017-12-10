var app = angular.module("classroom", ["ui.router"]);

app.run(function($rootScope, $location, $state, LoginService) {
    $rootScope.$on("$stateChangeStart", function(event, toState, toParams, fromState, fromParams) {
        console.log("Changed state to: " + toState);
    });

    if (!LoginService.is_authenticated()) {
        $state.transitionTo("login");
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

app.factory("LoginService", function() {
    var allowed_credentials = { username: "teacher", password: "best" };
    var _is_authenticated = false;

    return {
        login: function(user) {
            _is_authenticated =
                user.username === allowed_credentials.username &&
                user.password === allowed_credentials.password;
            return _is_authenticated;
        },
        logout: function() {
          _is_authenticated = false;
        },
        is_authenticated: function() {
            return _is_authenticated;
        }
    };
});
