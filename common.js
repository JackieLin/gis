// Generated by CoffeeScript 1.9.3

/*
 * 公共方法
 * @author jackie Lin <dashi_lin@163.com>
 */
var _;

_ = require('lodash');


/*
 * clone 对象 ( 深度克隆 )
 */

exports.clone = function(fn) {
  var object;
  object = _.isFunction(fn) ? fn() : fn;
  return JSON.parse(JSON.stringify(object || {}));
};
