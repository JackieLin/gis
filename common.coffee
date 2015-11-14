###
 * 公共方法
 * @author jackie Lin <dashi_lin@163.com>
###

_ = require 'lodash'

###
 * clone 对象 ( 深度克隆 )
###
exports.clone = (fn) ->
    object = if _.isFunction(fn) then fn() else fn
    JSON.parse JSON.stringify(object or {})

