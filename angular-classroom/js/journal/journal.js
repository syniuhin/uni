app.component("journal", {
  bindings: {
    data: "<"
  },
  templateUrl: "html/journal.html",
  controller: ["StorageService", "DataService", JournalComponent]
});

function JournalComponent(StorageService, DataService, data) {
  var me = this;

  me.$onInit = function() {
    var key = `journal.${me.data.year}.${me.data.subject}`;
    // Check if the journal is built.
    var journal = StorageService.load(key);
    if (journal === undefined) {
      journal = {};
    }
    DataService.buildJournal(journal, me.data.year, me.data.subject);
    StorageService.createOrUpdate(key, journal, existing => {
      existing.lessons = journal.lessons;
      return existing;
    });
  };

  me.pupils = function() {
    return DataService.getPupils(me.data.year);
  };

  me.lessons = function() {
    return DataService.getJournalLessons(me.data.year, me.data.subject);
  };

  me.getMark = function(pupil, lesson) {};
}
