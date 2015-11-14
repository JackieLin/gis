###
 * 处理 require js 文件的相关细节
 * @author jackie Lin <dashi_lin@163.com>
###
path = require 'path'

###
 * 生成基本的配置信息
 * @return {String} config
###
exports.getBaseDevConfig = (config) ->
    JSON.stringify config.requireConfig, null, 4
    

exports.getBaseConfig = (config) ->
    JSON.stringify config.requireConfig


###
 * 根据配置返回 config.js 文件
 * @return {String}  require js string
###
exports.generator = (config) ->
    """
        requirejs.config(#{config});
    """
