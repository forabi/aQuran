// var request = require('request');
var Dexie = require('Dexie');

var db = new Dexie('aQuran');

var definitions = require('./db-definitions.coffee');

definitions.forEach(function(database) {
    database.versions.forEach(function(version) {
        var stores = { };
        version.tables.forEach(function(table) {
            stores[table.table_name] = table.schema;
            
        });
        db.version(version.version).stores(stores);
        version.tables.forEach(function(table) {
            if (table.hasOwnProperty('hooks')) {
                for (key in table.hooks) {
                    db[table.table_name].hook(key, table.hooks[key]);
                }
            }
        });
    });
})

var db_init = require('./db-init.coffee');


db.on('ready', function() {
    console.log('HERE!');
    var promises = [];
    var tables = definitions[0].versions[0].tables;
    console.log('Tables!', tables);

    for (var i = 0; i < tables.length; i++) {
        promises.push(db_init.populate(db, tables[i]));
    };

    return Dexie.Promise.all(promises);
});

// db.ayas.hook('creating', function(primKey, obj, trans) {
//     if ('string' == typeof obj.standard) {
//         obj.words = obj.standard.split(' ');
//     }
// });

module.exports = db;