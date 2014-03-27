gulp            = require 'gulp'
gutil           = require 'gulp-util'
_               = require 'lodash'
Q               = require 'q'

fs              = require 'fs'
path            = require 'path'
async           = require 'async'
glob            = require 'glob'

sqlite3         = require 'sqlite3'
properties      = require 'properties'
admZip          = require 'adm-zip'

plugins = (require 'gulp-load-plugins')()
config = _.defaults gutil.env,
    target: 'web' # web, chrome, firefox
    nightly: no # whether to use the latest ionic nightly build
    port: 7000 # on which port the server is hosted
    production: yes
    minfiy: yes # whether to minfiy resources for production
    sourceMaps: yes
    bump: yes # whether to increase the version of the app on 'release'
    experimental: yes # whether to use the Uthmanic script by Khaled Hosny
    translations: yes # true, false, or an array of translations to include
    recitations: yes # whether to include recitations metadata
    src:
        ionic: 'ionic/**/*'
        icons: 'icons/*.png'
        manifest: 'manifest.coffee'
        database: 'database/main.db'
        recitations: 'resources/recitations.js'
        translations: 'resources/translations/*.trans.zip'
        hosny: 'khaledhosny-quran/quran/*.txt'
        less: 'styles/main.less'
        css: 'styles/*.css'
        jade: ['index.jade', 'views/*.jade']
        coffee: ['*.coffee', 'scripts/**/*.coffee']
        js: 'scripts/*.js'
        bundles: [
            ['ionic/js/ionic.bundle.min.js', 'ionic/js/angular/angular-sanitize.min.js']
            ['async.js', 'nedb.js', 'lodash.js', 'idbstore.js']
            ['ngStorage.js', 'angular-audio-player.js']
            [
                'main.js'

                # Services
                'scripts/services/cache-service.js'
                'scripts/services/preferences-service.js'
                'scripts/services/localization-service.js'
                'scripts/services/api-service.js'
                'scripts/services/recitation-service.js'
                'scripts/services/content-service.js'
                'scripts/services/search-service.js'
                'scripts/services/explanation-service.js'
                'scripts/services/storage-service.js'
                'scripts/services/arabic-service.js'

                # Factories
                'scripts/factories/explanation-factory.js'
                'scripts/factories/audio-src-factory.js'
                'scripts/factories/query-builder.js'
                'scripts/factories/idbstore-factory.js'

                'scripts/filters/arabic-number-filter.js'

                # Directives
                'scripts/directives/auto-direction-directive.js'
                'scripts/directives/emphasize-directive.js'
                'scripts/directives/colorize-directive.js'

                # Controller
                'scripts/controllers/aya-controller.js'
                'scripts/controllers/preferences-controller.js'
                'scripts/controllers/recitations-controller.js'
                'scripts/controllers/explanations-controller.js'
                'scripts/controllers/navigation-controller.js'
                'scripts/controllers/search-controller.js'
                'scripts/controllers/reading-controller.js'
            ]
        ]

try
    fs.mkdirSync "dist"
    fs.mkdirSync "dist/#{config.target}"
    fs.mkdirSync "dist/#{config.target}/resources"
    fs.mkdirSync "dist/#{config.target}/translations" if config.translations
    fs.mkdirSync "dist/#{config.target}/icons"

gulp.task 'clean', () ->
    gulp.src config.target, cwd: 'dist'
    .pipe plugins.clean()

gulp.task 'manifest', () ->
    gulp.src config.src.manifest, cwd: 'src'
    .pipe plugins.cson()
    .pipe plugins.rename (file) ->
        file.extname = '.webapp' if config.target is not 'chrome'
        file
    .pipe gulp.dest "dist/#{config.target}"

gulp.task 'ionic', () ->
    gulp.src config.src.ionic, cwd: 'src'
    .pipe gulp.dest "dist/#{config.target}/ionic"

gulp.task 'less', () ->
    gulp.src config.src.less, cwd: 'src'
    .pipe plugins.less sourceMap: config.sourceMaps, compress: config.minify
    .pipe gulp.dest "dist/#{config.target}/styles"

gulp.task 'css', () ->
    gulp.src config.src.css, cwd: 'src'
    .pipe gulp.dest "dist/#{config.target}/styles"

gulp.task 'styles', ['less', 'css']

gulp.task 'jade', () ->
    scripts = [] # TODO
    styles = []

    gulp.src config.src.jade, cwd: 'src', base: 'src'
    .pipe plugins.jade
        pretty: not config.minify
        locals:
            scripts: scripts
            styles: styles
    .pipe gulp.dest "dist/#{config.target}"

gulp.task 'html', ['jade']

gulp.task 'coffee', () ->
    stream = gulp.src config.src.coffee, cwd: 'src'
    .pipe plugins.coffee bare: yes
    # .pipe plugins.uglify()
    stream.pipe gulp.dest "dist/#{config.target}/scripts"

gulp.task 'js', () ->
    gulp.src config.src.js, cwd: 'src'
    # .pipe plugins.uglify()
    .pipe gulp.dest "dist/#{config.target}/scripts"

gulp.task 'scripts', ['coffee', 'js']

gulp.task 'icons', () ->
    gulp.src config.src.icons, cwd: 'src'
    # .pipe plugins.optimize()
    .pipe gulp.dest "dist/#{config.target}/icons"

gulp.task 'images', ['icons']

gulp.task 'quran', (callback) ->
    db = new sqlite3.Database("src/#{config.src.database}", sqlite3.OPEN_READONLY);
    db.all 'SELECT * FROM aya ORDER BY gid', (err, rows) ->
        write = (json) ->
            fs.writeFile "dist/#{config.target}/resources/quran.json", json, callback

        if config.experimental
            # process
            files = glob.sync config.src.hosny, cwd: 'src'
            numbers = /[٠١٢٣٤٥٦٧٨٩]+/g
            strip = /\u06DD|[٠١٢٣٤٥٦٧٨٩]/g;
            
            process = (file) ->
                deferred = Q.defer()
                fs.readFile (path.join 'src', file), (err, data) ->
                    if err then throw err
                    text = data.toString()
                    aya_ids = text.match numbers
                    sura_id = Number file.match /\d+/g
                    
                    text = text.replace strip, ''
                    .trim()
                    .split '\n'
                    .map (line, index) ->
                        sura_id: sura_id
                        aya_id_display: aya_ids[index]
                        uthmani: line.trim()
                    deferred.resolve text
                deferred.promise

            Q.all files.map process
            .then (suras) ->
                _.flatten suras
            .then (json) ->
                _.merge rows, json
            .then(JSON.stringify)
            .then(write)
            
        else write JSON.stringify rows

gulp.task 'search', ['quran'], () ->
    gulp.src "dist/#{config.target}/resources/quran.json"
    .pipe plugins.jsonEditor (ayas) ->
        ayas.map (aya) -> _.pick aya, 'gid', 'standard', 'standard_full'
    .pipe plugins.rename (file) ->
        file.basename = 'search'
        file
    .pipe gulp.dest "dist/#{config.target}/resources"

gulp.task 'translations', () ->
    write = (json) ->
        fs.writeFileSync "dist/#{config.target}/resources/translations.json", json

    process = (file) ->
        deferred = Q.defer()
        file = new admZip path.join 'src', file
        entries = file.getEntries()
        props = undefined
        async.each entries, (entry, callback) ->
            if entry.name.match /.properties$/gi
                text = entry.getData().toString 'utf-8'
                properties.parse text, (err, obj) ->
                    if err then throw err
                    props = obj
                    callback err
            else if entry.name.match /.txt$/gi
                file.extractEntryTo entry.name, "dist/#{config.target}/resources/translations", no, yes
                callback()
        , (err) ->
            if err then throw err
            deferred.resolve props

        deferred.promise

    if config.translations
        files = switch 
            when typeof config.translations is 'string'
                config.translations.split /,/g
                .map (id) -> "resources/translations/#{id}.trans.zip"
            when config.translations instanceof Array then config.translations.map (file) -> "src/resources/translations/#{file}.trans.zip"
            else glob.sync 'resources/translations/*.trans.zip', cwd: 'src'

        Q.all files.map process
        .then(JSON.stringify)
        .then(write)

gulp.task 'recitations', () ->
    gulp.src config.src.recitations, cwd: 'src'
    .pipe plugins.rename (file) ->
        file.extname = '.json'
        file
    .pipe plugins.jsonEditor (json) ->
        delete json.ayahCount
        _.chain json
        .each (item, key) ->
            item.index = Number key - 1
            item
        .toArray()
        .sortBy 'index'
        .each (item) ->
            delete item.index
            item
        .value()
    .pipe gulp.dest "dist/#{config.target}/resources"

gulp.task 'release', ['clean'], () ->
    
    config.production = yes
    config.minify = yes
    
    if config.bump
        config.version += 1
        config.date = new Date()

    gulp.run 'build'

gulp.task 'data', ['quran', 'recitations', 'translations', 'search']
gulp.task 'build', ['data', 'images', 'scripts', 'styles', 'html', 'ionic', 'manifest']

gulp.task 'serve', () ->
