app.factory("DataService", [
  "StorageService",
  function(StorageService) {
    return {
      loadDefaults: function(stateService, httpService) {
        stateService.transitionTo("wait");
        httpService
          .get("data/classes.json", { cache: true })
          .then(function(classes_data) {
            StorageService.save("defaults", {
              years: ["9A", "9C", "10B", "11A"],
              subjects: ["Math", "History", "Physics", "Humanities"],
              lessons: [
                "2017-12-01, 4",
                "2017-12-02, 1",
                "2017-12-02, 2",
                "2017-12-02, 3",
                "2017-12-02, 4",
                "2017-12-05, 3",
                "2017-12-06, 3",
                "2017-12-07, 3"
              ],
              classes: classes_data.data.classes
            });
            stateService.transitionTo("login");
          });
      },

      getYears: function() {
        return StorageService.load("defaults")
          .years.concat(StorageService.loadOr("data_points_year", []))
          .sort();
      },

      getSubjects: function() {
        return StorageService.load("defaults")
          .subjects.concat(StorageService.loadOr("data_points_subject", []))
          .sort();
      },

      getLessons: function() {
        return StorageService.load("defaults")
          .lessons.concat(StorageService.loadOr("data_points_lesson", []))
          .sort();
      },

      getPupils: function(year) {
        var pupils = StorageService.load(`pupils_of_${year}`);
        if (pupils === undefined) {
          var cls = StorageService.load("defaults").classes.find(
            c => c.year === year
          );
          pupils = cls === undefined ? [] : cls.pupils;
        }
        return pupils === undefined ? [] : pupils.sort();
      },

      // Make a single string from an array to show in a form.
      getPupilsPretty: function(year) {
        return this.getPupils(year).join("\n");
      },

      updatePupilsIn: function(cls) {
        var pupils = cls.pupilsPretty.split("\n");
        StorageService.save(`pupils_of_${cls.year}`, pupils);
      },

      getEntries: function() {
        return StorageService.loadOr("entries", []);
      },

      createNewEntry: function(entry) {
        StorageService.createOrUpdate("entries", [entry], existing => {
          existing.push(entry);
          return existing;
        });
      },

      getJournalLessons: function(year, subject) {
        return StorageService.loadOr("entries", [])
          .filter(e => e.year === year && e.subject === subject)
          .map(e => e.lesson)
          .sort();
      },

      buildJournal: function(journal, year, subject) {
        journal.pupils = this.getPupils();
        journal.lessons = this.getJournalLessons(year, subject);
        journal.year = year;
        journal.subject = subject;
      }
    };
  }
]);
