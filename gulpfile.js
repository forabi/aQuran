var gulp = require('gulp'),
    rename = require('gulp-rename'),
    jade = require('gulp-jade'),
    less = require('gulp-less'),
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
    scripts: ['src/scripts/*.coffee'],
    styles: 'src/styles/main.less',
    jade: 'src/index.jade',
    images: 'src/images/*',
    manifest: 'src/manifest.json',
    locales: ['src/_locales/**/*.*']
};

gulp.task('styles', function() {
    return gulp.src(paths.styles, { base: './src/styles' })
    .pipe(less({
        sourceMap: true,
        compress: true
    }))
    .pipe(gulp.dest('dist/chrome/styles'));
});

gulp.task('scripts', function() {
    return gulp.src(paths.scripts, { read: false })
    .pipe(ngmin())
    .pipe(browserify({
        transform: ['coffeeify'],
        extensions: ['.coffee'],
        debug: true
    }))
    .pipe(rename(function(file) {
        file.extname = '.js';
    }))
    .pipe(gulp.dest('dist/chrome/scripts'));
});

gulp.task('html', function() {
    return gulp.src(paths.jade)
    .pipe(jade({
        pretty: false,
        locals: {
            scripts: ['scripts/main.js'],
            styles: ['styles/main.css']
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

gulp.task('build', ['manifest', 'locales', 'scripts', 'html', 'styles', 'images']);

gulp.task('watch', function() {
    // var server = livereload();
    gulp.watch(paths.scripts, ['scripts'])/*.on('change', function(file) {
        server.changed(file.path);
    })*/;
});

gulp.task('default', ['build', 'watch']);