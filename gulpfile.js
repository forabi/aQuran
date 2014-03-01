var gulp = require('gulp'),
    gutil = require('gulp-util'),
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
    resources: ['src/resources/*.json', 'src/styles/fonts/*']
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
                'scripts/q.js',
                'scripts/async.js',
                'scripts/nedb.js',
                'ionic/js/ionic.bundle.min.js',
                'scripts/main.js',
                'scripts/services/localization-service.js',
                'scripts/directives/auto-direction-directive.js',
                'scripts/controllers/search-controller.js',
                'scripts/controllers/reading-controller.js',
                'scripts/directives/colorize-directive.js',
                'scripts/services/storage-service.js',
                'scripts/services/arabic-service.js',
                'scripts/filters/arabic-number-filter.js',
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

gulp.task('build', ['manifest', 'locales', 'scripts', 'html', 'styles', 'images']);

gulp.task('watch', function() {
    // var server = livereload();
    gulp.watch([paths.coffee, paths.js], ['scripts', 'html']);
    gulp.watch(paths.jade, ['html']);
    gulp.watch(paths.styles, ['styles']);
    
});

gulp.task('default', ['build', 'watch']);