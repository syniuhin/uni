app.factory("LoginService", [
  "StorageService",
  function(StorageService) {
    var allowed_credentials = { username: "teacher", password: "best" };

    return {
      login: function(user) {
        var _is_authenticated =
          user.username === allowed_credentials.username &&
          user.password === allowed_credentials.password;
        StorageService.save("is_authenticated", _is_authenticated);
        return _is_authenticated;
      },
      logout: function() {
        StorageService.save("is_authenticated", false);
      },
      isAuthenticated: function() {
        return StorageService.load("is_authenticated");
      }
    };
  }
]);
