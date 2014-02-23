var sqlite3 = require('sqlite3');

module.exports = function(grunt) {

    var config = grunt.config('database');

    var db = new sqlite3.Database(config.path, sqlite3.OPEN_READONLY);

    var models = [{
        name: 'Aya',
        query: 'SELECT * FROM aya;',
        transform: function(result, callback) {
            callback(null, result);
        }
    }];


    grunt.registerTask('db', function(args) {
        
        var done = this.async();

        db.all('SELECT * FROM aya;', function(err, rows) {

            if (err) return grunt.fatal(err.message);

            grunt.log.ok('Found', rows.length, 'rows');

            grunt.file.write('app/resources/ayas.json', JSON.stringify(rows));

            done();

        });

    });

}