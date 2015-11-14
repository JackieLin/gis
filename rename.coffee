###
 * 对文件进行重命名
 * @author jackie Lin <dashi_lin@163.com>
###
'use strict'

through2 = require 'through2'
path = require 'path'
_ = require 'lodash'

module.exports = (fn)->
    through2.obj (file, enc, callback) ->
        file = if _.isFunction(fn) then fn(file) else fn
        callback null, file
