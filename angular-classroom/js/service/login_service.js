app.factory("LoginService", [
  "StorageService",
  function(StorageService) {
    var allowed_credentials = { username: "teacher", password: "best" };
    var _is_authenticated = false;

    return {
      login: function(user) {
        _is_authenticated =
          user.username === allowed_credentials.username &&
          user.password === allowed_credentials.password;
        StorageService.save("is_authenticated", _is_authenticated);
        return _is_authenticated;
      },
      logout: function() {
        _is_authenticated = false;
        StorageService.save("is_authenticated", false);
      },
      isAuthenticated: function() {
        if (StorageService.load("is_authenticated")) {
          _is_authenticated = true;
        }
        return _is_authenticated;
      }
    };
  }
]);
