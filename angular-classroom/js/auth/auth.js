app.controller("AuthController", [
    "$scope",
    "$state",
    "LoginService",
    function($scope, $state, LoginService) {
        var me = this;
        me.update = function(user) {
            if (LoginService.login(user)) {
                user.username = "";
                user.password = "";
                me.error = "";
                $state.transitionTo("home");
            } else {
                me.error = "Incorrect credentials!";
            }
        };
    }
]);
