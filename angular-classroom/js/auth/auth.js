app.controller("AuthController", [
  "$scope",
  "$state",
  "LoginService",
  function($scope, $state, LoginService) {
    var me = this;
    me.tryLogin = function(user) {
      if (LoginService.login(user)) {
        user.username = "";
        user.password = "";
        me.error = "";
        $state.transitionTo("home");
      } else {
        me.error = "Incorrect credentials!";
      }
    };

    me.logout = function() {
      LoginService.logout();
      $state.transitionTo("login");
    };

    me.isLoggedOut = function() {
      return !LoginService.isAuthenticated();
    };
  }
]);
