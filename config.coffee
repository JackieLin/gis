###
 * 处理配置文件相关的细节
 * @author jackie Lin <dashi_lin@163.com>
###
path = require 'path'
FS = require 'q-io/fs'
_ = require 'lodash'

baseConfigPath = path.join __dirname, 'gis.json'
configPath = ''

config = ->
    config.readConfig baseConfigPath
        .then (baseObj)->
            baseObj = JSON.parse baseObj
            # console.log baseObj
            config.readConfig configPath
                .then (obj) ->
                    # console.log obj
                    obj = JSON.parse obj
                    _.extend baseObj, obj


config.readConfig = (path)->
    FS.exists path
        .then (stat)->
            return FS.read path if stat
            return '{}' if not stat


config.setPath = (path) ->
    throw new Error 'config: path is null' if not path?
    configPath = path
    config


config.getPath = ->
    configPath


# For test
# config.setPath '/Users/jackielin/work/atido/mmfclient/static/fbuild.json'
# config().then (res) ->
#     console.log res

module.exports = config
