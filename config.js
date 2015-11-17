// Generated by CoffeeScript 1.9.3

/*
 * 处理配置文件相关的细节
 * @author jackie Lin <dashi_lin@163.com>
 */
var FS, _, baseConfigPath, config, configPath, path;

path = require('path');

FS = require('q-io/fs');

_ = require('lodash');

baseConfigPath = path.join(__dirname, 'gis.json');

configPath = '';

config = function() {
  return config.readConfig(baseConfigPath).then(function(baseObj) {
    baseObj = JSON.parse(baseObj);
    return config.readConfig(configPath).then(function(obj) {
      obj = JSON.parse(obj);
      return _.extend(baseObj, obj);
    });
  });
};

config.readConfig = function(path) {
  return FS.exists(path).then(function(stat) {
    if (stat) {
      return FS.read(path);
    }
    if (!stat) {
      return '{}';
    }
  });
};

config.setPath = function(path) {
  if (path == null) {
    throw new Error('config: path is null');
  }
  configPath = path;
  return config;
};

config.getPath = function() {
  return configPath;
};

module.exports = config;