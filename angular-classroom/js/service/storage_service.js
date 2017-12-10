app.factory("StorageService", [
  "$cookies",
  function($cookies) {
    return {
      save: function(kv) {
        if (kv.value !== null && typeof kv.value === "object") {
          $cookies.putObject(kv.key, kv.value);
          this._putInObjectMap(kv.key);
        } else {
          $cookies.put(kv.key, kv.value);
        }
      },
      load: function(key) {
        if (this._isInObjectMap(key)) {
          return $cookies.getObject(key);
        }
        return $cookies.get(key);
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
