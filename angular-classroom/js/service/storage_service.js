app.factory("StorageService", [
  "$cookies",
  function($cookies) {
    // For ng directives to not become insane.
    var cache = {};

    return {
      save: function(key, value) {
        $cookies.putObject(key, value);
        if (cache.hasOwnProperty(key)) {
          delete cache[key];
        }
      },

      createOrUpdate: function(key, value, value_fn) {
        if (!this.contains(key)) {
          this.save(key, value);
        } else {
          var value_new = value_fn(this.load(key));
          this.save(key, value_new);
        }
      },

      load: function(key) {
        if (cache.hasOwnProperty(key)) {
          return cache[key];
        }
        var res = $cookies.getObject(key);
        cache[key] = res;
        return res;
      },

      loadOr: function(key, empty_value) {
        var result = this.load(key);
        return result === undefined ? empty_value : result;
      },

      contains: function(key) {
        return this.load(key) !== undefined;
      }
    };
  }
]);
