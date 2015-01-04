'use strict'

# PLUGINS
gulp = require 'gulp'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
browserify = require 'browserify'
sync = require 'browser-sync'
del = require 'del'
runSequence = require 'run-sequence'
$ = require('gulp-load-plugins')()

config = require './config.json'
handleErrors = require './handleErrors.js'

# jade コンパイル
gulp.task 'jade', ->
    gulp.src ['dev/jade/**/*.jade', '!dev/jade/**/_*.jade']
    .pipe $.plumber()
    .pipe $.jade
        pretty: true
        locals : config
    .pipe gulp.dest 'public'

# gulp.task 'sass', ->
#     gulp.src 'dev/sass/**/*.scss'
#     .pipe plumber()
#     .pipe sourcemaps.init()
#     .pipe sass
#         errLogToConsole: true
#     .pipe pleeease
#         autoprefixer :
#             browsers : 'last 2 versions'
#         minifier : false
#     .pipe sourcemaps.write('.')
#     .pipe gulp.dest 'public/css'

# sass コンパイル
gulp.task 'sass', ->
    gulp.src 'dev/sass/**/*.scss'
    .pipe $.plumber()
    .pipe $.rubySass(
        style : 'expanded'
        precision : 10
        compass : true
        'sourcemap=file' : true
        sourcemapPath : 'dev/sass/'
    ).on 'error', console.error.bind(console)
    .pipe $.sourcemaps.init()
    .pipe $.autoprefixer('last 2 versions', 'ie 9', 'ie 8')
    .pipe $.sourcemaps.write('.')
    .pipe gulp.dest 'public/css'

# sass コンパイル
# gulp.task 'sass', ->
#     gulp.src 'dev/sass/**/*.scss'
#     .pipe $.plumber()
#     .pipe $.compass
#         config_file : 'dev/config.rb'
#         css: 'public/css/',
#         sass: 'dev/sass/',
#         image: 'public/img/',
#     .pipe gulp.dest 'public'

# browserify jsの圧縮結合
gulp.task 'browserify', ->
    browserify
        entries: ['./dev/coffee/test.coffee']
        extensions: ['.coffee', '.js']
        debug : true
    .transform 'coffeeify'
    .bundle()
    .on('error', handleErrors)
    .pipe source 'bundle.js'
    .pipe buffer()
    .pipe $.sourcemaps.init loadMaps: true
    #.pipe $.uglify()
    .pipe $.sourcemaps.write('./')
    .pipe gulp.dest 'public/js'

gulp.task 'jshint', ->
    gulp.src 'public/js/**/*.js'
    .pipe $.jshint()
    .pipe $.jshint.reporter('jshint-stylish')

# 画像最適化
gulp.task 'images', ->
    gulp.src 'dev/img/*'
    .pipe $.imagemin
        optimizationLevel : 7
        progressive : true
        interlaced : true
    .pipe gulp.dest('public/img')

gulp.task 'spritesmith', ->
    spriteData = gulp.src 'dev/img/sprite/*.png'
    .pipe $.spritesmith
        imgName : 'sprite.png'
        cssName : '_sprite.scss'
        imgPath : '../img/sprite.png'
        algorithm : 'top-down'
        padding : 10
    spriteData.img.pipe gulp.dest('dev/img')
    spriteData.css.pipe gulp.dest('dev/sass')

# public 初期化
gulp.task 'clean', del.bind(null, ['public'])

# サーバ起動
gulp.task 'sync', ->
    sync.init null,
        server :
            baseDir : 'public'

# ブラウザオートリロード
gulp.task 'reload', ->
    sync.reload()
    
# WATCH
gulp.task 'watch', ->
    gulp.watch 'dev/jade/**/*.jade', ['jade']
    gulp.watch 'dev/sass/**/*.scss', ['sass']
    gulp.watch 'dev/coffee/**/*.coffee', ['browserify']
    gulp.watch 'dev/img/sprite/*.png', ['spritesmith']
    gulp.watch 'dev/img/*', ['images']
    gulp.watch 'public/js/*.js', ['jshint']
    gulp.watch ['public/**', '!public/**/*.map', '!public/img'], ['reload']

gulp.task 'init', ->
    runSequence 'clean', 'sass', [ 'spritesmith', 'jshint', 'jade', 'browserify', 'images']

gulp.task 'default', ['sync','watch']