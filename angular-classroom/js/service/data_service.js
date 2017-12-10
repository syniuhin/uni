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
              years: ["9A", "10B", "11A"],
              subjects: ["Math", "History", "Physics"],
              lessons: ["01/12, 4", "02/12, 1"],
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
        var cls = StorageService.load("defaults").classes.find(
          c => c.year === year
        );
        return cls === undefined ? [] : cls.pupils.sort();
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
