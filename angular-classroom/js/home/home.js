app.controller("HomeController", [
    "$scope",
    "$state",
    "LoginService",
    function($scope, $state, LoginService) {
        var me = this;

        me.logout = function() {
          LoginService.logout();
          $state.transitionTo("login");
        };
    }
]);
