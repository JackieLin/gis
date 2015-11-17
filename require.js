// Generated by CoffeeScript 1.9.3

/*
 * 处理 require js 文件的相关细节
 * @author jackie Lin <dashi_lin@163.com>
 */
'use strict';
var FS, config, generator, getConfig, getDevConfig, init, path, through2, writeConfigFile;

through2 = require('through2');

path = require('path');

config = {};

FS = require('q-io/fs');


/*
 * 生成基本的配置信息
 * @return {String} config
 */

getDevConfig = function(msg) {
  return JSON.stringify(msg, null, 4);
};

getConfig = function(msg) {
  return JSON.stringify(msg);
};


/*
 * 根据配置返回 config.js 文件
 * @return {String}  require js string
 */

generator = function(configMsg) {
  return "requirejs.config(" + configMsg + ");";
};


/*
 * 初始化 config 信息
 */

init = function(config) {
  config.requireObj = {};
  config.requireConfig.paths = config.requireConfig.paths || {};
  config.requireObj.baseUrl = path.join(config.sourePath, config.requireConfig.baseUrl);
  return config;
};


/*
 * 设置配置文件信息
 */

exports.setConfig = function(projectConfig) {
  config = projectConfig;
  return init(config);
};


/*
 * 写入配置文件
 */

writeConfigFile = function() {
  var dev, production, sourePath;
  sourePath = config.sourePath;
  production = FS.join(sourePath, config.configFile.production);
  dev = FS.join(sourePath, config.configFile.dev);
  FS.write(production, generator(getConfig(config.requireConfig)));
  return FS.write(dev, generator(getDevConfig(config.requireConfig)));
};


/*
 * 重新生成 config 文件信息
 */

exports.rebuild = function(fileKey) {
  return through2.obj(function(file, enc, callback) {
    var baseName, key;
    baseName = path.basename(file.path, '.js');
    key = fileKey(baseName);
    config.requireConfig.paths[key] = './' + path.join(path.relative(config.requireObj.baseUrl || '', file.path), '../', baseName);
    writeConfigFile();
    return callback(null, file);
  });
};

exports.getDevConfig = getDevConfig;

exports.getConfig = getConfig;

exports.generator = generator;

exports.writeConfigFile = writeConfigFile;