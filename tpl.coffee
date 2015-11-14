###
 * tpl 打包 ( 单页应用需要 )
 * @author jackie Lin <dashi_lin@163.com>
###
'use strict'

through2 = require 'through2'
FS = require "q-io/fs"
path = require 'path'
_ = require 'lodash'

###
 * 生成 tpl 信息
###
buildTpl = (contents, title='') ->
    """
        define("#{title}", function() {
            "use strict";
            return #{contents}
        });
    """

###
 * 获取 require 文件信息
###
getRequireKey = (srcPath) ->
    baseName = path.basename srcPath
    packageName = path.basename path.join(srcPath, '../')

    packageName + '/' + baseName


exports.build = ->
    fileList = []

    through2.obj (file, enc, callback) ->
        srcPath = file.path

        FS.stat srcPath
        .then (stat) ->
            throw new Error '%s is not directory', srcPath if stat.isDirectory() is false
            FS.list srcPath

        .then (list) ->
            _.select list, (item) ->
                path.extname(item) is '.html'

        .then (list) ->
            task = []
            # 下一个方法需要
            fileList = list
            list.forEach (v) ->
                task.push FS.read(path.join(srcPath, v))

            task

        .spread ->
            content = {}
            args = Array.prototype.slice.call arguments

            fileList.forEach (v, k) ->
                content[v] = args[k]

            fileName = path.basename srcPath

            file.contents = new Buffer buildTpl(JSON.stringify(content), getRequireKey(srcPath))
            file.path = path.join srcPath, fileName + '.min.js'

            # console.log file.path

            # console.log args
            callback null, file

        .fail (err) ->
            callback err, null
