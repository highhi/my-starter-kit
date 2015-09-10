var gulp = require( 'gulp' );
var sync = require( 'browser-sync' );
var del = require( 'del' );
var plumber = require( 'gulp-plumber' );
var rename = require( 'gulp-rename' );
var sourceMaps = require( 'gulp-sourcemaps' );

var DIR_MAPS = '../_maps';

var DIR_PUBLIC = './public';
var DIR_PUBLIC_CSS = './public/css';
var DIR_PUBLIC_JS = './public/js';
var DIR_PUBLIC_MAPS = './public/_maps';

var DIR_DEV_SCSS = './dev/scss';
var DIR_DEV_JS = './dev/js';

var DEV_HTML_FILES = './dev/**/*.html';
var DEV_SCSS_FILES = './dev/scss/*.scss';
var DEV_JS_FILES = './dev/js/**/*.js';


gulp.task('minify-html', function() {
    var minifyHtml = require( 'gulp-minify-html' );

    return gulp.src( DEV_HTML_FILES )
        .pipe( plumber() )
        .pipe( minifyHtml({
            conditionals: true,
            quotes: true
        }))
        .pipe( gulp.dest( DIR_PUBLIC ) );
});

gulp.task('build-css', function() {
    var rubySass = require( 'gulp-ruby-sass' );
    var pleeease = require( 'gulp-pleeease' );

    return rubySass( DIR_DEV_SCSS, {
        style: 'compressed',
        compass : true,
        sourcemap : true
    })
    .pipe( plumber() )
    .pipe( pleeease({
        autoprefixer : { 
            'browsers': ['last 4 versions', 'Android 2.3']
        }
    }))
    .pipe( rename({
        extname: '.min.css'
    }))
    .pipe( sourceMaps.write( DIR_MAPS, {
        includeContent : false,
        sourceRoot : DIR_PUBLIC_MAPS
    }))
    .pipe( gulp.dest( DIR_PUBLIC_CSS ) );
});

// gulp.task('minify-js', function() {
//     var jshint = require( 'gulp-jshint' );
//     var uglify = require( 'gulp-uglify' );

//     return gulp.src( DEV_JS_FILES )
//         .pipe( plumber() )
//         .pipe( jshint() )
//         .pipe( jshint.reporter( 'jshint-stylish' ) )
//         .pipe( sourceMaps.init() )
//         .pipe( uglify() )
//         .pipe( sourceMaps.write( DIR_MAPS, {
//             sourceRoot: DEV_JS_FILES
//         }))
//         .pipe( gulp.dest( DIR_PUBLIC_JS ) );
// });

gulp.task('build-js', function() {
    var browserify = require( 'browserify' );
    var source = require( 'vinyl-source-stream' );
    var buffer = require( 'vinyl-buffer' );
    var uglify = require( 'gulp-uglify' );

    return browserify({
            entries : [ DIR_DEV_JS + '/main.js' ],
            debug : true
        })
        .bundle()
        .on( 'error', function( err ) {
            console.log("Error : " + err.message);
        })
        .pipe( source( 'bundle.js' ) )
        .pipe( buffer() )
        .pipe( sourceMaps.init({
            loadMaps : true
        }))
        .pipe( uglify() )
        .pipe( sourceMaps.write( DIR_MAPS, {
            includeContent : false,
            sourceRoot : DIR_PUBLIC_MAPS
        }))
        .pipe( gulp.dest( DIR_PUBLIC_JS ) );
});

gulp.task( 'clean', del.bind( null, [ DIR_PUBLIC ] ) );

gulp.task( 'init', function() {
    var seque = require( 'run-sequence' );
    return seque( 'clean', ['build-js', 'build-css', 'minify-html'] );
});
    

gulp.task('sync', function() {
    return sync.init( null, {
        server : {
            baseDir: DIR_PUBLIC
        }
    });
});

gulp.task( 'reload', function() {
    return sync.reload();
});

gulp.task('watch', function() {
    gulp.watch( DEV_HTML_FILES, ['minify-html'] );
    gulp.watch( DEV_SCSS_FILES, ['build-css'] );
    gulp.watch( DEV_JS_FILES, ['build-js'] );
    gulp.watch( [ DIR_PUBLIC + '/**' ], ['reload'] );
});

gulp.task('default', [ 'sync', 'watch' ]);