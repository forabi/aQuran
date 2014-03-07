var gulp = require('gulp'),
    gutil = require('gulp-util'),
    fs = require('fs'),
    async = require('async'),
    admZip = require('adm-zip'),
    properties = require('properties'),
    glob = require('glob'),
    rename = require('gulp-rename'),
    jade = require('gulp-jade'),
    less = require('gulp-less'),
    coffee = require('gulp-coffee'),
    // coffeelint = require('gulp-coffeelint'),
    livereload = require('gulp-livereload'),
    ngmin = require('gulp-ngmin'),
    uglify = require('gulp-uglify'),
    browserify = require('gulp-browserify');

var copy = function(src, dest, options) {
    return gulp.src(src, options)
    .pipe(gulp.dest(dest));
}

var paths = {
    ionic: 'src/ionic/**/*',
    coffee: ['src/*.coffee', 'src/scripts/**/*.coffee'],
    js: ['src/scripts/*.js'],
    styles: ['src/styles/main.less', 'src/styles/*.css'],
    jade: ['src/index.jade', 'src/views/*.jade'],
    images: 'src/images/*',
    manifest: 'src/manifest.json',
    locales: ['src/_locales/**/*.*'],
    resources: ['src/resources/**/*', 'src/styles/fonts/*'],
    translations: 'src/resources/translations/*.trans.zip'
};

gulp.task('ionic', function() {
    return gulp.src(paths.ionic, { base: 'src' })
    .pipe(gulp.dest('dist/chrome'));
});

gulp.task('styles', function() {
    return gulp.src(paths.styles, { base: 'src/styles' })
    .pipe(less({
        sourceMap: true,
        compress: false
    }))
    .pipe(gulp.dest('dist/chrome/styles'));
});

gulp.task('scripts', function() {
    gulp.src(paths.coffee, { /*read: false,*/ base: 'src' })
    // .pipe(browserify({
    //     transform: ['coffeeify'],
    //     extensions: ['.coffee'],
    //     debug: true
    // }))
    // .pipe(rename(function(file) {
    //     file.extname = '.js';
    // }))
    .pipe(coffee({ bare: true }))
    .pipe(gulp.dest('dist/chrome'));
    
    gulp.src(paths.js, { base: 'src' })
    .pipe(gulp.dest('dist/chrome'))
});

gulp.task('html', function() {
    return gulp.src(paths.jade, { base: 'src' })
    .pipe(jade({
        pretty: true,
        locals: {
            scripts:  [
                // 'ionic/js/angular/angular.js',
                // 'ionic/js/angular/angular-resource.js',
                // 'ionic/js/angular/angular-animate.js',
                // 'ionic/js/angular-ui/angular-ui-router.js',
                // 'ionic/js/ionic.js',
                'scripts/lodash.js',
                // 'scripts/q.js',
                'scripts/async.js',
                'scripts/nedb.js',
                'ionic/js/ionic.bundle.min.js',
                'scripts/angular-audio-player.min.js',
                'scripts/main.js',
                'scripts/services/preferences-service.js',
                'scripts/services/localization-service.js',
                'scripts/services/explanation-service.js',
                'scripts/directives/auto-direction-directive.js',
                'scripts/controllers/aya-controller.js',
                'scripts/controllers/preferences-controller.js',
                'scripts/controllers/navigation-controller.js',
                'scripts/controllers/search-controller.js',
                'scripts/controllers/reading-controller.js',
                'scripts/directives/emphasize-directive.js',
                'scripts/directives/colorize-directive.js',
                'scripts/services/storage-service.js',
                'scripts/services/arabic-service.js',
                'scripts/filters/arabic-number-filter.js',
                'scripts/services/api-service.js',
                'scripts/services/recitation-service.js',
                'scripts/services/content-service.js',
                'scripts/services/search-service.js'
                ],
            styles: ['ionic/css/ionic.min.css', 'styles/main.css']
        }
    })).pipe(gulp.dest('dist/chrome'));
});

gulp.task('images', function() {
    return copy(paths.images, 'dist/chrome/images');
});

gulp.task('manifest', function() {
    return copy(paths.manifest, 'dist/chrome');
});

gulp.task('locales', function() {
    return copy(paths.locales, 'dist/chrome', { base: 'src' });
});

gulp.task('res', function() {
    return copy(paths.resources, 'dist/chrome', { base: 'src' });
});

gulp.task('translations', function(callback) {
    var files = glob.sync(paths.translations);
    console.log('Translations files:', files);
    var processFile = function(file) {
        console.log('Processing file', file);
        var zip = new admZip(file);
        var entries = zip.getEntries();
        var props = {};
        async.each(entries, function(entry, callback) {
            if (entry.name.match(/.properties$/gi)) {
                properties.parse(entry.getData().toString('utf-8'), function(err, obj) {
                    props = obj;
                    callback(err);
                });
            } else if (entry.name.match(/.txt$/gi)) {
                zip.extractEntryTo(entry.name, 'dist/chrome/resources/translations', false, true);
            }
        }, function(err) {
            callback(err, props)
        });
    };
    async.map(files, processFile, function(err, translations) {
        translations = JSON.stringify(translations);
        fs.writeFile('dist/chrome/resources/translations.json', translations, {flags: 'w+'}, callback);
    });
});

gulp.task('build', ['manifest', 'res', 'locales', 'scripts', 'html', 'styles', 'images']);

gulp.task('watch', function() {
    // var server = livereload();
    gulp.watch(paths.coffee, paths.js, ['scripts', 'html']);
    gulp.watch(paths.jade, ['html']);
    gulp.watch(paths.styles, ['styles']);
    gulp.watch(paths.resources, ['res']);
    
});

gulp.task('default', ['build', 'watch']);