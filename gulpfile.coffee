###
 * gulp file 配置
 * @author jackie Lin <dashi_lin@163.com>
###

'use strict'

gulp = require 'gulp'
argv = require('yargs').argv
FS = require 'q-io/fs'
path = require 'path'
# 配置文件信息
config = require './config'
rename = require './rename'
# 处理 requirejs 信息
requirejs = require './require'

# js 打包
pack = require './pack'
# tpl 打包
tpl = require './tpl'

# 删除
deleteFile = require './deleteFile'

_ = require 'lodash'

through2 = require 'through2'
# 压缩
uglify = require 'gulp-uglify'
# md5
md5 = require "gulp-md5"

# 浏览器
browserSync = require('browser-sync').create()

###
 * 获取配置文件对象
 * @return Promise
###
getConfig = (sourePath='')->
    config.setPath sourePath
    config()

###
 * 生成 roadMap 信息
 * @example
 *     [{'widget/src': ***}, ***]
 * @return {Array}
###
getExcludeList = (config={})->
    roadMap = config.roadMap or []
    packPath = config.pack or ''
    sourePath = config.sourePath or ''

    _.chain roadMap
    .map (item) ->
        basePath = item.path
        item.exclude = (item.exclude or []).map (v, k)->
            # console.log v
            path.join sourePath, packPath, basePath, v

        item

    .pluck 'exclude'
    .flatten().value()

###
 * 设置 packTask 过滤信息
###
packFilter = (config={})->
    # 过滤列表
    packFilter = getExcludeList config if not exports.packFilter and config.roadMap
    packFilter


###
 * js 打包任务
 * @param {String} filePath 文件目录所在路径
###
packTask = (filePath, filter) ->
    srcPath = path.dirname filePath
    # console.log srcPath
    gulp.src filePath
        .pipe pack.combineFile(filter)
        .pipe deleteFile(path.join(srcPath, './dist'))
        .pipe gulp.dest(path.join(srcPath, './dist'))
        .pipe requirejs.rebuildDev((baseName) ->
            baseName.split('.')[0]
        )
        .pipe uglify()
        .pipe rename((file) ->
            file.path = file.path.replace 'all.js', 'all.min.js'
            file
        )
        .pipe md5(6)
        .pipe gulp.dest(path.join(srcPath, './dist'))
        .pipe requirejs.rebuild((baseName) ->
            baseName.split('.')[0]
        )

###
 * 编译模板文件
###
tplTask = (filePath, packPath) ->
    baseName = path.basename filePath

    gulp.src filePath
    .pipe deleteFile(path.join(packPath, './tpl', baseName))
    .pipe tpl.build()
    .pipe md5(6)
    .pipe gulp.dest(path.join(packPath, './tpl'))
    .pipe requirejs.rebuild((baseName) ->
        'tpl/' + baseName.split('.')[0]
    )


###
 * 构建对应的目录信息
###
buildPath = (srcPath, done)->
    FS.stat srcPath
    .then (stat) ->
        throw new Error '%s srcPath is null', srcPath if stat.isDirectory() is false
        FS.list srcPath
    .then (list) ->
        list.forEach (v) ->
            do (v)->
                if v.indexOf('.') isnt 0
                    done v


###
 * 打包所有 js 目录
###
packAll = (config)->
    # 监听文件列表
    srcPath = path.join config.sourePath, config.pack

    # 过滤列表
    filter = packFilter config

    # 构建开始
    buildPath srcPath, (v)->
        packTask path.join(srcPath, v, 'src'), filter


###
 * 打包所有的模板文件
###
buildAllTpl = (config) ->
    # 监听文件列表
    srcPath = path.join config.sourePath, config.tpl
    packPath = path.join config.sourePath, config.pack, '../'

    # 构建开始
    buildPath srcPath, (v)->
        tplTask path.join(srcPath, v), packPath


###
 * 监听模板的变化
 * @param {String} tplPath 模板路径
 * @param {String} tplBuildPath 模板保存路径
 * @param {Boolean} [browserReload] 是否刷新浏览器
###
watchTpl = (tplPath, tplBuildPath, browserReload=false)->
    gulp.watch tplPath, (event) ->
        console.log 'build tpl: %s', event.path

        filePath = path.dirname event.path
        tplTask filePath, tplBuildPath


###
 * 初始化任务
###
initTask = (sourePath) ->
    srcPath = if sourePath then path.join(sourePath, 'gis.json') else ''

    getConfig srcPath
    .then (config) =>
        # 设置 requirejs config 信息
        config.sourePath = sourePath
        requirejs.setConfig config
        pack.setConfig config

        config


###
 * 执行初始化任务
 * @example
 *     gulp init --path=path
###
gulp.task 'init', ->
    sourePath = argv.path
    throw new Error 'init task: path is null' if not sourePath
    getConfig()
    .then (config) ->
        config.sourePath = sourePath
        requirejs.setConfig config

        FS.makeTree path.join sourePath, config.pack
        .then ->
            FS.makeTree path.join sourePath, config.sass
        .then ->
            FS.makeTree path.join sourePath, config.tpl
        .then ->
            FS.copy path.join(__dirname, 'gis.json'), path.join(sourePath, 'gis.json')
        .then ->
            requirejs.writeConfigFile()


gulp.task 'rebuild', ->
    sourePath = argv.path    
    throw new Error 'init task: path is null' if not sourePath

    initTask sourePath
    .then (config) ->
        # 重新生成 config 文件
        requirejs.writeConfigFile()
        
        packAll config
        buildAllTpl config if config.tplBuild


gulp.task 'watch', ->
    sourePath = argv.path    
    throw new Error 'init task: path is null' if not sourePath

    initTask sourePath
    .then (config) =>
        packPath = path.join sourePath, config.pack, '**/src/*.js'
        # 过滤列表
        filter = packFilter config

        # start http server
        (browserSync.init
            server: 
                baseDir: sourePath
        ) if config.browserReload

        gulp.watch packPath, (event) ->
            console.log 'build pack: %s', event.path
            
            filePath = path.dirname event.path
            # console.log event.path
            packTask filePath, filter

        # 编译模板文件
        if config.tplBuild
            tplPath = path.join sourePath, config.tpl, '**/*.html'
            tplBuildPath = path.join sourePath, config.pack, '../'

            watchTpl tplPath, tplBuildPath, config.browserReload if not config.browserReload
            
            (watchTpl tplPath, tplBuildPath, config.browserReload
             .on 'change', browserSync.reload) if config.browserReload
