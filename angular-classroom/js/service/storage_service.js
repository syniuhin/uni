app.factory("StorageService", [
  "$cookies",
  function($cookies) {
    return {
      save: function(key, value) {
        if (value !== null && typeof value === "object") {
          $cookies.putObject(key, value);
          this._putInObjectMap(key);
        } else {
          $cookies.put(key, value);
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
        if (this._isInObjectMap(key)) {
          return $cookies.getObject(key);
        }
        return $cookies.get(key);
      },

      loadOr: function(key, empty_value) {
        var result = this.load(key);
        return result === undefined ? empty_value : result;
      },

      contains: function(key) {
        return this.load(key) !== undefined;
      },

      _putInObjectMap: function(key) {
        // Check if this is the first entry.
        if ($cookies.getObject("object_map") === undefined) {
          $cookies.putObject("object_map", {});
        }
        var object_map = $cookies.getObject("object_map");
        if (!$cookies.getObject("object_map").hasOwnProperty(key)) {
          object_map[key] = true;
          $cookies.putObject("object_map", object_map);
        }
      },

      _isInObjectMap: function(key) {
        return (
          $cookies.getObject("object_map") !== undefined &&
          $cookies.getObject("object_map").hasOwnProperty(key)
        );
      }
    };
  }
]);
