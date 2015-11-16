###
 * 删除文件或者是某个目录
 * @author jackie Lin <dashi_lin@163.com>
###
'use strict'

through2 = require 'through2'
FS = require 'q-io/fs'
path = require 'path'
_ = require 'lodash'

module.exports = (filePath) ->
    filePath = if _.isFunction(filePath) then filePath() else filePath

    # console.log filePath
    through2.obj (file, enc, callback) ->
        FS.stat filePath
        .then (stat) ->
            return FS.list filePath if stat.isDirectory()
            return [] if not stat.isDirectory()

        .then (list) ->
            task = []
            list.forEach (v) ->
                task.push FS.remove(path.join(filePath, v))
            
            task
        .spread ->
            # console.log file.contents.toString()
            callback null, file

        .fail (err) ->
            # console.log err
            callback null, file
