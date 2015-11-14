###
 * javascript 打包
 * @author jackie Lin <dashi_lin @163.com>
###

'use strict'
through2 = require 'through2'
FS = require "q-io/fs"
path = require 'path'
_ = require 'lodash'

###
 * 将对应目录的文件进行合并
###
exports.combineFile = (config, filterList)->
    through2.obj (file, enc, callback) ->
        srcPath = file.path
        # console.log srcPath
        # console.log path.join(srcPath, 'src')
        FS.stat srcPath
        .then (stat)->
            throw new Error '%s is not directory', srcPath if stat.isDirectory() is false
            FS.list srcPath
        .then (list) ->
            # console.log list
            # 过滤出 js 文件
            _.select list, (item) ->
                path.extname(item) is '.js' and not (path.join(srcPath, item) in filterList)

        .then (list) ->
            hasIndex = false
            task = []
            # console.log list
            list.forEach (v) ->
                # require index
                hasIndex = v if v.indexOf(config.index or 'index.js') >= 0
                task.push FS.read(path.join(srcPath, v)) if v.indexOf(config.index or 'index.js') < 0
                return

            # console.log hasIndex
            task.push FS.read(path.join(srcPath, hasIndex)) if hasIndex
            task

        .spread ->
            args = Array.prototype.slice.call arguments
            source = args.join(';')

            name = _.chain srcPath.split(path.sep)
                    .initial().last()

            name = name + '.all.js'

            # console.log name
            file.contents = new Buffer source
            file.path = path.join srcPath, '../', name
            # console.log file.path
            callback null, file

        .fail (err)->
            callback err, file
