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
 * 初始化 config 信息
###
init = (config) ->
    config.requireObj = {}
    config.requireConfig.paths = config.requireConfig.paths or {}
    # 补全 require js baseUrl 的全路径
    config.requireObj.baseUrl = path.join config.sourePath, config.requireConfig.baseUrl

    config


###
 * 设置配置文件信息
###
exports.setConfig = (projectConfig) ->
    config = projectConfig
    init config


###
 * 初始化配置文件信息
###
initConfigFile = ->
    sourePath = config.sourePath
    production = FS.join sourePath, config.configFile.production
    dev = FS.join sourePath, config.configFile.dev

    FS.write production, generator(getConfig(config.requireConfig))
    FS.write dev, generator(getDevConfig(config.requireConfig))


###
 * 修改发布地址
###
changeBaseUrl = (url)->
    sourePath = config.sourePath
    production = FS.join sourePath, config.configFile.production
    dev = FS.join sourePath, config.configFile.dev

    readConfigFile dev, (content)->
        content.baseUrl = url
        FS.write dev, generator(getDevConfig(content))
        FS.write production, generator(getConfig(content))


###
 * 写入配置文件
 * @param {Function} method getConfig || getDevConfig
###
writeConfigFile = (configFilePath, method=->)->
    sourePath = config.sourePath
    configFile = FS.join sourePath, configFilePath

    FS.write configFile, generator(method(config.requireConfig))


###
 * 获取 requireJs paths 相对路径
###
getRelativePath = ->
    requireOption = config.requireOption or {}
    cwd = requireOption.cwd or config.requireObj.baseUrl
    path.join config.sourePath, cwd


###
 * 生成配置信息
###
writeConfig = (filePath, fileKey=->) ->
    baseName = path.basename filePath, '.js'
    key = fileKey baseName

    config.requireConfig.paths[key] = path.join path.relative(getRelativePath(), filePath), '../', baseName


###
 * 读取生成配置文件
###
rebuildConfig = (configPath, filePath, fileKey, method, done=->)->
    sourePath = config.sourePath
    configFilePath = path.join sourePath, configPath

    readConfigFile configFilePath, (content)->
        # 获取路径信息
        obj = getPathList content

        # console.log obj
        for k, v of obj
            config.requireConfig.paths[k] = v

        writeConfig filePath, fileKey
        
        # 重新生成生产环境写入配置文件
        writeConfigFile configPath, method

        done()


###
 * 重新生成 config dev 信息
###
exports.rebuildDev = (fileKey) ->
    through2.obj (file, enc, callback) ->
        rebuildConfig config.configFile.dev, file.path, fileKey, getDevConfig, ->
            callback null, file


###
 * 重新生成 config 文件信息
###
exports.rebuild = (fileKey)->
    through2.obj (file, enc, callback) ->
        rebuildConfig config.configFile.production, file.path, fileKey, getConfig, ->
            callback null, file

###
 * 获取 Requirejs 配置对象
###
getRequireConfigObj = (configString) ->
    configString = configString.replace 'requirejs.config(', ''
    configString = configString.replace ');', ''
    
    JSON.parse configString


###
 * 设置路径信息
###
getPathList = (content)->
    content.paths or {}

###
 * 读取配置文件信息
###
readConfigFile = (configFile, done=->) ->
    FS.stat configFile
    .then (stat) ->
        throw new Error '%s is not a string', configFile if not stat.isFile()
        FS.read configFile
    .then (content) ->
        done getRequireConfigObj(content)


exports.getDevConfig = getDevConfig
exports.getConfig = getConfig
exports.generator = generator
exports.writeConfigFile = writeConfigFile
exports.initConfigFile = initConfigFile
exports.changeBaseUrl = changeBaseUrl
