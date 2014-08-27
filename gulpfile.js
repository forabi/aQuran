var gulp = require('gulp'),
    fs = require('fs'),
    sqlite3 = require('sqlite3'),
    stripDiacritics = require('./ar-utils').stripDiacritics;

var db = new sqlite3.Database('main.db', sqlite3.OPEN_READONLY);

gulp.task('synonyms', function(done) {
    var stmt = 'SELECT word, synonymes FROM synonymes';
    db.all(stmt, function(err, rows) {
        if (err) {
            throw err;
            return;
        }
        var results = [];
        for (var i = 0, length = rows.length; i < length; i++) {
            var row = rows[i];
            var word_full = row.word,
                word_no_diacritics = stripDiacritics(word_full);

            results[i] = {
                word: word_no_diacritics,
                word_full: word_full,
                synonyms: row.synonymes.split(',')
            }
        }

        fs.writeFile('./db/synonyms.json', JSON.stringify(results), done);
    });
});