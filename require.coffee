###
 * 处理 require js 文件的相关细节
 * @author jackie Lin <dashi_lin@163.com>
###
'use strict'

through2 = require 'through2'
path = require 'path'
config = {}
FS = require 'q-io/fs'

###
 * 生成基本的配置信息
 * @return {String} config
###
getDevConfig = (msg)->
    JSON.stringify msg, null, 4


getConfig = (msg)->
    JSON.stringify msg


###
 * 根据配置返回 config.js 文件
 * @return {String}  require js string
###
generator = (configMsg) ->
    """
        requirejs.config(#{configMsg});
    """

###
 * 设置配置文件信息
###
exports.setConfig = (projectConfig) ->
    config = projectConfig
    config.requireConfig.paths = config.requireConfig.paths or {}
    config


###
 * 写入配置文件
###
writeConfigFile = ->
    sourePath = config.sourePath
    production = FS.join sourePath, config.configFile.production
    dev = FS.join sourePath, config.configFile.dev

    FS.write production, generator(getConfig(config.requireConfig))
    FS.write dev, generator(getDevConfig(config.requireConfig))

###
 * 重新生成 config 文件信息
###
exports.rebuild = ->
    through2.obj (file, enc, callback) ->
        baseName = path.basename file.path, '.js'
        key = baseName.split('.')[0]
        config.requireConfig.paths[key] = baseName
        # 重新写入配置文件
        writeConfigFile()

        callback null, file


exports.getDevConfig = getDevConfig
exports.getConfig = getConfig
exports.generator = generator
exports.writeConfigFile = writeConfigFile
