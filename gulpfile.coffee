###
 * gulp file 配置
 * 
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
# 处理 requireJs 信息
requirejs = require './require'
# 过滤器
gulpFilter = require 'gulp-filter'

pack = require './pack'

_ = require 'lodash'

through2 = require 'through2'
# 压缩
uglify = require 'gulp-uglify'
# md5
md5 = require "gulp-md5"

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
getExcludeList = (roadMap)->
    _.chain roadMap
    .map (item) ->
        basePath = item.path
        item.exclude = (item.exclude or []).map (v, k)->
            path.join basePath, v

        item

    .pluck 'exclude'
    .flatten().value()


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
        FS.makeTree path.join sourePath, config.pack
        .then ->
            FS.makeTree path.join sourePath, config.sass
        .then ->
            FS.makeTree path.join sourePath, config.tpl
        .then ->
            FS.copy path.join(__dirname, 'gis.json'), path.join(sourePath, 'gis.json')
        .then ->
            production = FS.join sourePath, config.configFile.production
            dev = FS.join sourePath, config.configFile.dev
            FS.write production, requirejs.generator(requirejs.getBaseConfig(config))
            FS.write dev, requirejs.generator(requirejs.getBaseDevConfig(config))

###
 * 默认任务
 * @example
 *     gulp --path=path
###
# gulp.task 'default', ->
#     sourePath = argv.path    
#     throw new Error 'init task: path is null' if not sourePath

#     getConfig path.join(sourePath, 'gis.json')
#     .then (config) =>
#         # excludeFilter = ['*']
#         console.log sourePath
#         # 监听文件列表
#         watchPath = path.join sourePath, config.pack, '**/src/*.js'
#         if config.roadMap
#             excludeList = getExcludeList config.roadMap

#             # unExcludeList = excludeList.map (v) ->
#             #     '!' + v

#             # unExcludeList.unshift '*'
#             excludeFilter = gulpFilter jsExcludeFilter(excludeList),
#                                 restore: true

#         # console.log watchPath
#         # console.log process.cwd()
#         gulp.src watchPath
#         .pipe excludeFilter
#         .pipe pack.combineFile(config)
#         .pipe gulp.dest path.join(sourePath, config.pack, 'dist')
gulp.task 'default', ->
    sourePath = argv.path    
    throw new Error 'init task: path is null' if not sourePath

    getConfig path.join(sourePath, 'gis.json')
    .then (config) =>
        # console.log sourePath
        # 监听文件列表
        srcPath = path.join sourePath, config.pack

        if config.roadMap
            # 过滤列表
            filterList = getExcludeList config.roadMap

            # unExcludeList = excludeList.map (v) ->
            #     '!' + v

            # unExcludeList.unshift '*'

        FS.stat srcPath
        .then (stat) ->
            throw new Error '%s srcPath is null', srcPath if stat.isDirectory() is false
            FS.list srcPath
        .then (list) ->
            list.forEach (v) ->
                do (v)->
                    if v.indexOf('.') isnt 0
                        # console.log path.join srcPath, v, 'src'
                        gulp.src path.join srcPath, v, 'src'
                        .pipe pack.combineFile(config, filterList)
                        .pipe gulp.dest(path.join(srcPath, v, './dist'))
                        .pipe uglify()
                        .pipe rename((file) ->
                            file.path = file.path.replace 'all.js', 'all.min.js'
                            file
                        )
                        .pipe md5()
                        .pipe gulp.dest(path.join(srcPath, v, './dist'))


jsExcludeFilter = (filterList) ->
    (file) ->
        console.log file.path
        not (file.path in filterList)
