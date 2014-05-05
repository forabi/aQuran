gulp            = require 'gulp'
gutil           = require 'gulp-util'
_               = require 'lodash'
Q               = require 'q'
combine         = require 'stream-combiner'

fs              = require 'graceful-fs'
through         = require 'through'
path            = require 'path'
async           = require 'async'
glob            = require 'glob'

sqlite3         = require 'sqlite3'
properties      = require 'properties'
admZip          = require 'adm-zip'
connect         = require 'connect'

plugins = (require 'gulp-load-plugins')()

minifyJSON = ->
    plugins.tap (file) ->
        json = JSON.parse file.contents.toString()
        file.contents = new Buffer JSON.stringify json
        file

config = _.defaults gutil.env,
    target: switch
        when gutil.env.cordova or gutil.env.android or gutil.env.ios then 'cordova'
        when gutil.env.chrome then 'chrome'
        when gutil.env.firefox then 'firefox'
        else 'web' # web, chrome, firefox
    name: 'aQuran'
    version: 1
    port: 7000 # on which port the server will be listening
    env: if gutil.env.production then 'production' else 'development'
    bump: yes # whether to increase the version of the app on 'release'
    download: no # if set to false, assume we already have
                 # recitations metadata and translation packages downloaded
    translations: yes # true, false, or an array of translations to include
    recitations: yes # whether to include recitations metadata
    styles: []
    scripts: []
    icons: []
    countries: ['*'] # countries which have translations, used to copy
                     # the corresponding flags to destination
    bower: 'src/bower'
    cacheManifest: 'manifest.cache' # name of HTML5's ApplicationCache manifest file
    bundles: [ # bundles are used to concatenate and minify files, we use multiple
               # bundles so users do not have to redownload a large file even
               # if most of it did not change.
               # We keep non-frequently changing files in separate bundles.
        (file: 'ionic.js', src: [
            'ionic.bundle.js'
            'angular-sanitize.js'
            ]
        )
        (file: 'utils.js', src: [
            'async.js'
            'nedb*.js'
            'lodash*.js'
            'idbstore.js'
            ]
        )
        (file: 'ng-modules.js', src: [
            'bindonce*.js'
            'ngStorage.js'
            'angular-media-player*.js'
            ]
        )
    ]
    src:
        icons: 'icons/*.png'
        manifest: 'manifest.coffee'
        database: 'database/main.db'
        translations: 'resources/translations/*.trans.zip'
        translationsTxt: 'resources/translations.txt'
        hosny: 'khaledhosny-quran/quran/*.txt'
        scss: 'styles/main.scss'
        css: 'styles/*.css'
        jade: ['index.jade', 'views/*.jade']
        coffee: ['!chromereload.coffee', '!launcher.coffee', '!manifest.coffee', 'scripts/**/*.coffee']
        js: 'scripts/*.js'
    watch:
        scss: 'styles/**/*.scss'
        jade: ['*.jade', '*/**/*.jade']
    coffeeConcat:
        file: 'main.js'
        src: [
            'main*'

            # Services
            '*/**/services/*'

            # Factories
            '*/**/factories/*'

            # Filters
            '*/**/filters/*'

            # Directives
            '*/**/directives/*'

            # Controllers
            '*/**/controllers/*'
        ]
if config.env isnt 'production'
    config = _.defaults config,
        lint: yes
        sourceMaps: yes
        experimental: yes # whether to use the Uthmanic script by Khaled Hosny
else
    config = _.defaults config,
        experimental: yes

config.dest = if config.target isnt 'cordova'
        "dist/#{config.target}/#{config.env}"
    else 'www'


try
    fs.mkdirpSync cofig.dest
    fs.mkdirSync "#{config.dest}/scripts"
    fs.mkdirSync "#{config.dest}/resources"
    fs.mkdirSync "#{config.dest}/translations" if config.translations
    fs.mkdirSync "#{config.dest}/icons"

gulp.task 'watch', ->
    # server = livereload();
    gulp.watch config.src.manifest, cwd: 'src', ['manifest']
    gulp.watch [config.src.coffee, config.src.js], cwd: 'src', ['scripts', 'styles', 'html']
    gulp.watch config.watch.jade, cwd: 'src', ['styles', 'html']
    gulp.watch config.watch.scss, cwd: 'src', ['styles']

gulp.task 'clean', ->
    gulp.src ['**/*', '!.gitignore'], cwd: config.dest
    .pipe plugins.clean()

gulp.task 'manifest', ->
    gulp.src config.src.manifest, cwd: 'src'
    .pipe plugins.cson()
    .pipe plugins.jsonEditor (json) ->
        # Chrome expects an array of permission keys
        json.permissions = _.keys json.permissions if config.target is 'chrome'
        json
    .pipe plugins.rename (file) ->
        # Firefox packaged apps must have the manifest file named 'manifset.webapp'
        file.extname = '.webapp' if config.target isnt 'chrome'
        file
    .pipe if config.env is 'production' then minifyJSON() else gutil.noop()
    .pipe gulp.dest config.dest

gulp.task 'flags', ->
    gulp.src (config.countries.map (country) -> "flags/1x1/#{country.toLowerCase()}.*"), cwd: "#{config.bower}/flag-icon-css"
    .pipe plugins.using()
    .pipe plugins.cached()
    .pipe gulp.dest "#{config.dest}/styles/flag-icon-css/flags/1x1"

gulp.task 'scss', ['flags', 'css'], ->
    gulp.src config.src.scss, cwd: 'src'
    .pipe plugins.sass
        sourceComments: if config.env isnt 'production' then 'map'
        outputStyle: if config.env is 'production' then 'compressed'
        includePaths: [config.bower]
    .pipe plugins.using()
    .pipe plugins.cached()
    .pipe plugins.tap (file) ->
        config.styles.push path.relative 'src', file.path
    .pipe gulp.dest "#{config.dest}/styles"

gulp.task 'fonts', ->
    plugins.bowerFiles()
    .pipe plugins.filter ['**/fonts/*']
    .pipe plugins.using()
    .pipe plugins.cached()
    .pipe gulp.dest "#{config.dest}/styles"

gulp.task 'css', ['fonts'], ->
    plugins.bowerFiles()
    .pipe plugins.filter [
        # '**/ionic/**/*.css'
        '**/flag-icon-css/css/flag-icon.css'
    ]
    .pipe plugins.using()
    .pipe if config.env is 'production' then plugins.minifyCss keepSpecialComments: 0 else gutil.noop()
    .pipe plugins.tap (file) ->
        config.styles.push path.join 'styles', path.relative config.bower, file.path
    .pipe plugins.cached()
    .pipe gulp.dest "#{config.dest}/styles"

gulp.task 'amiri', ->
    gulp.src 'resources/amiri/*.ttf', cwd: 'src', base: 'src'
    .pipe plugins.cached()
    .pipe gulp.dest config.dest

gulp.task 'styles', ['css', 'scss', 'amiri']

gulp.task 'jade', ['scripts', 'styles', 'icons'], ->

    scripts = _.uniq config.scripts || [] # TODO
    styles = _.uniq config.styles || []
    icons = _.uniq config.icons, (icon) -> icon.size || []

    gulp.src config.src.jade, cwd: 'src', base: 'src'
    .pipe plugins.using()
    .pipe plugins.jade
        pretty: config.env isnt 'production'
        locals:
            scripts: scripts
            styles: styles
            icons: icons
            manifest: config.cacheManifest if config.env is 'production'
    .pipe gulp.dest config.dest

gulp.task 'html', ['jade']

gulp.task 'coffee', ['js'], ->
    gulp.src config.src.coffee, cwd: 'src'
    .pipe (if config.lint then plugins.coffeelint() else gutil.noop())
    .pipe (if config.lint then plugins.coffeelint.reporter() else gutil.noop())
    .pipe plugins.coffee bare: yes, sourceMap: (yes if config.env isnt 'production')
    .pipe (plugins.order config.coffeeConcat.src)
    .pipe (if config.env is 'production' then plugins.concat config.coffeeConcat.file else gutil.noop())
    .pipe (if config.env is 'production' then plugins.uglify() else gutil.noop())
    .pipe (plugins.order config.coffeeConcat.src)
    .pipe plugins.tap (file) ->
        config.scripts.push path.relative 'src', file.path if !file.path.match /.map$/gi
    .pipe gulp.dest "#{config.dest}/scripts"

gulp.task 'js', (callback) ->
    bundle = (bundle) ->
        src = bundle.src.map (file) -> "*/**/#{file}"
        gutil.log 'Bundling file', gutil.colors.cyan bundle.file + '...'
        Q.when (plugins.bowerFiles()
            .pipe plugins.filter src
            .pipe plugins.order src
            .pipe (if config.env is 'production' then plugins.uglify() else gutil.noop())
            .pipe plugins.concat bundle.file
            .pipe gulp.dest "#{config.dest}/scripts"
        )

    config.scripts = config.bundles.map (bundle) -> "scripts/#{bundle.file}"
    Q.all config.bundles.map bundle

gulp.task 'scripts', ['js', 'coffee']

gulp.task 'icons', ->
    gulp.src config.src.icons, cwd: 'src'
    # .pipe plugins.optimize()
    .pipe plugins.tap (file) ->
        size = path.basename(file.path).match(/(\d+).*/i)[1]
        config.icons.push
            path: path.relative 'src', file.path
            size: "#{size}x#{size}"
    .pipe gulp.dest "#{config.dest}/icons"

gulp.task 'images', ['icons']

gulp.task 'quran', (callback) ->
    db = new sqlite3.Database("src/#{config.src.database}", sqlite3.OPEN_READONLY);
    db.all 'SELECT gid, aya_id, page_id, juz_id, sura_id, standard, standard_full, sura_name, sura_name_en, sura_name_romanization FROM aya ORDER BY gid', (err, rows) ->
        if config.experimental
            numbers = /[٠١٢٣٤٥٦٧٨٩]+/g # Hindi numbers
            strip = /\u06DD|[٠١٢٣٤٥٦٧٨٩]/g # Aya number and aya sign

            concat = (filename) ->
                joinedContent = []

                process = (file) ->
                    text = file.contents.toString()
                    aya_ids = text.match numbers # Get aya_ids from file contents
                    sura_id = Number path.basename(file.path).match /\d+/g # Get sura_id from filename

                    text = text.replace strip, '' # Strip aya number and aya sign
                    .trim()
                    .split '\n'
                    .map (line, index) ->
                        sura_id: sura_id
                        aya_id_display: aya_ids[index]
                        uthmani: line.trim()
                    joinedContent = Array.prototype.concat joinedContent, text

                endStream = ->
                    joinedFile = new gutil.File
                        path: filename
                        contents: new Buffer JSON.stringify _.merge joinedContent, rows
                    @emit 'data', joinedFile
                    @emit 'end'

                through process, endStream

            gulp.src config.src.hosny, cwd: 'src'
            .pipe plugins.using()
            .pipe plugins.cached()
            .pipe concat 'quran.json'
            .pipe if config.env is 'production' then minifyJSON() else gutil.noop()
            .pipe gulp.dest "#{config.dest}/resources"
            .on 'end', -> callback()
        else
            data = JSON.stringify rows
            fs.writeFile "#{config.dest}/resources/quran.json", data, callback

gulp.task 'search', ['quran'], ->
    gulp.src "#{config.dest}/resources/quran.json"
    .pipe plugins.jsonEditor (ayas) ->
        # A subset of quran.json that only contains texts,
        # should be light enough to load in memory for offline search
        ayas.map (aya) -> _.pick aya, 'gid', 'standard', 'standard_full'
    .pipe plugins.rename (file) ->
        file.basename = 'search'
        file
    .pipe if config.env is 'production' then minifyJSON() else gutil.noop()
    .pipe gulp.dest "#{config.dest}/resources"

gulp.task 'translations', ->
    ids = []
    urls = # Load URLs of translation packages from translations.txt
        fs.readFileSync "src/#{config.src.translationsTxt}"
        .toString().split /\n/g

    concat = (filename) ->
        files = []
        json = []
        process = (file) ->
            self = @
            gutil.log "[#{gutil.colors.green 'translations'}] Processing entry #{gutil.colors.cyan path.basename file.path}..."
            file = new admZip path.join file.path
            entries = file.getEntries()
            # Walk through zip contents and process each entry
            async.each entries, (entry, callback) ->
                if entry.name.match /.properties$/gi
                    text = entry.getData().toString 'utf-8'
                    props = properties.parse text, (err, props) ->
                        delete props.signature
                        delete props.delimiter if not props.delimiter
                        delete props.lineDelimiter if not props.lineDelimiter
                        json.push props
                        callback err
                else if entry.name.match /.txt$/gi
                    file = new gutil.File
                        contents: entry.getData()
                        path: "translations/#{entry.name}"
                    self.emit 'data', file
                    callback null
            , (err) ->
                files.push new gutil.File
                    contents: new Buffer JSON.stringify json
                    path: filename

        endStream = ->
            @emit 'data', file for file in files
            @emit 'end'

        through process, endStream

    flags = ->
        plugins.tap (file) ->
            items = JSON.parse file.contents.toString()
            config.countries = _.chain items
                .pluck 'country'
                .uniq().value()
            gutil.log 'Countries:', gutil.colors.green config.countries
            file

    if config.translations
        if typeof config.translations is 'string'
                config.translations = config.translations.split /,/g

        urls = switch
            when config.translations instanceof Array
                config.translations.map (id) ->
                    regex = new RegExp ".+\/#{id}.*.trans.zip$", 'gi'
                    _.where urls, (url) ->
                        url.match regex
            else urls

        urls = _.chain(urls).flatten().uniq().value()
        # Extract IDs from URLs
        ids = urls.map (file) -> file.match(/.+\/(.+).trans.zip$/i)[1]
        files = ids.map (id) -> "resources/translations/#{id}.trans.zip"
        gutil.log 'Translations IDs', gutil.colors.green ids

        (
            if config.download
                plugins.download urls
                .pipe gulp.dest 'src/resources/translations'
            else
                gulp.src files, cwd: 'src'
        )
        .pipe plugins.cached()
        .pipe concat 'translations.json'
        # .pipe flags()
        .pipe gulp.dest "#{config.dest}/resources"

gulp.task 'recitations', ->
    (
        if not config.download then gulp.src 'resources/recitations.json', cwd: 'src'
        else
            plugins.download 'http://www.everyayah.com/data/recitations.js'
            .pipe plugins.rename (file) ->
                file.extname = '.json'
                file
            .pipe gulp.dest 'src/resources'
    )
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
    .pipe if config.env is 'production' then minifyJSON() else gutil.noop()
    .pipe gulp.dest "#{config.dest}/resources"

gulp.task 'cache', ['build'], ->
    if config.target is 'web' and config.env is 'production'
        gulp.src "#{config.dest}/**/*"
        .pipe plugins.manifest
            hash: yes
            timestamp: no
            filename: config.cacheManifest
            exclude:
                glob.sync("#{config.dest}/resources/translations/*.txt")
                .map (txt) -> path.relative config.dest, txt
                .concat [config.cacheManifest, 'resources/quran.json']
        .pipe gulp.dest config.dest
    else
        gulp.src "#{config.dest}/#{config.cacheManifest}"
        .pipe plugins.clean()

gulp.task 'package', ['build', 'cache'], ->
    switch config.target
        when 'chrome'
            '' # Do something
        when 'firefox'
            # Create a zip file
            zip = new admZip()
            zip.addLocalFolder config.dest
            zip.writeZip "dist/#{config.name.toLowerCase()}-#{config.target}-v#{config.version}.zip"
        else # Standard web app
            # Something

gulp.task 'release', ->
    if config.bump
        config.version += 1
        config.date = new Date()

gulp.task 'data', ['quran', 'recitations', 'translations', 'search']
gulp.task 'build', ['data', 'flags', 'images', 'scripts', 'styles', 'html', 'manifest']
gulp.task 'default', ['build', 'cache']

gulp.task 'serve', ->
    server = connect.createServer()
    server.use '/', connect.static "#{__dirname}/#{config.dest}"
    server.use '/', connect.static "#{__dirname}/src" if config.env isnt 'production'
    server.listen config.port, ->
        gutil.log "Server listening on port #{config.port}"