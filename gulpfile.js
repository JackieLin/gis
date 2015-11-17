// Generated by CoffeeScript 1.9.3

/*
 * gulp file 配置
 * @author jackie Lin <dashi_lin@163.com>
 */
'use strict';
var FS, _, argv, browserSync, buildAllTpl, buildPath, config, deleteFile, getConfig, getExcludeList, gulp, initTask, md5, pack, packAll, packFilter, packTask, path, rename, requirejs, through2, tpl, tplTask, uglify, watchTpl;

gulp = require('gulp');

argv = require('yargs').argv;

FS = require('q-io/fs');

path = require('path');

config = require('./config');

rename = require('./rename');

requirejs = require('./require');

pack = require('./pack');

tpl = require('./tpl');

deleteFile = require('./deleteFile');

_ = require('lodash');

through2 = require('through2');

uglify = require('gulp-uglify');

md5 = require("gulp-md5");

browserSync = require('browser-sync').create();


/*
 * 获取配置文件对象
 * @return Promise
 */

getConfig = function(sourePath) {
  if (sourePath == null) {
    sourePath = '';
  }
  config.setPath(sourePath);
  return config();
};


/*
 * 生成 roadMap 信息
 * @example
 *     [{'widget/src': ***}, ***]
 * @return {Array}
 */

getExcludeList = function(config) {
  var packPath, roadMap, sourePath;
  if (config == null) {
    config = {};
  }
  roadMap = config.roadMap || [];
  packPath = config.pack || '';
  sourePath = config.sourePath || '';
  return _.chain(roadMap).map(function(item) {
    var basePath;
    basePath = item.path;
    item.exclude = (item.exclude || []).map(function(v, k) {
      return path.join(sourePath, packPath, basePath, v);
    });
    return item;
  }).pluck('exclude').flatten().value();
};


/*
 * 设置 packTask 过滤信息
 */

packFilter = function(config) {
  if (config == null) {
    config = {};
  }
  if (!exports.packFilter && config.roadMap) {
    packFilter = getExcludeList(config);
  }
  return packFilter;
};


/*
 * js 打包任务
 * @param {String} filePath 文件目录所在路径
 */

packTask = function(filePath, filter) {
  var srcPath;
  srcPath = path.dirname(filePath);
  return gulp.src(filePath).pipe(pack.combineFile(filter)).pipe(deleteFile(path.join(srcPath, './dist'))).pipe(gulp.dest(path.join(srcPath, './dist'))).pipe(uglify()).pipe(rename(function(file) {
    file.path = file.path.replace('all.js', 'all.min.js');
    return file;
  })).pipe(md5(6)).pipe(gulp.dest(path.join(srcPath, './dist'))).pipe(requirejs.rebuild(function(baseName) {
    return baseName.split('.')[0];
  }));
};


/*
 * 编译模板文件
 */

tplTask = function(filePath, packPath) {
  var baseName;
  baseName = path.basename(filePath);
  return gulp.src(filePath).pipe(deleteFile(path.join(packPath, './tpl', baseName))).pipe(tpl.build()).pipe(md5(6)).pipe(gulp.dest(path.join(packPath, './tpl'))).pipe(requirejs.rebuild(function(baseName) {
    return 'tpl/' + baseName.split('.')[0];
  }));
};


/*
 * 构建对应的目录信息
 */

buildPath = function(srcPath, done) {
  return FS.stat(srcPath).then(function(stat) {
    if (stat.isDirectory() === false) {
      throw new Error('%s srcPath is null', srcPath);
    }
    return FS.list(srcPath);
  }).then(function(list) {
    return list.forEach(function(v) {
      return (function(v) {
        if (v.indexOf('.') !== 0) {
          return done(v);
        }
      })(v);
    });
  });
};


/*
 * 打包所有 js 目录
 */

packAll = function(config) {
  var filter, srcPath;
  srcPath = path.join(config.sourePath, config.pack);
  filter = packFilter(config);
  return buildPath(srcPath, function(v) {
    return packTask(path.join(srcPath, v, 'src'), filter);
  });
};


/*
 * 打包所有的模板文件
 */

buildAllTpl = function(config) {
  var packPath, srcPath;
  srcPath = path.join(config.sourePath, config.tpl);
  packPath = path.join(config.sourePath, config.pack, '../');
  return buildPath(srcPath, function(v) {
    return tplTask(path.join(srcPath, v), packPath);
  });
};


/*
 * 监听模板的变化
 * @param {String} tplPath 模板路径
 * @param {String} tplBuildPath 模板保存路径
 * @param {Boolean} [browserReload] 是否刷新浏览器
 */

watchTpl = function(tplPath, tplBuildPath, browserReload) {
  if (browserReload == null) {
    browserReload = false;
  }
  return gulp.watch(tplPath, function(event) {
    var filePath;
    console.log('build tpl: %s', event.path);
    filePath = path.dirname(event.path);
    return tplTask(filePath, tplBuildPath);
  });
};


/*
 * 初始化任务
 */

initTask = function(sourePath) {
  var srcPath;
  srcPath = sourePath ? path.join(sourePath, 'gis.json') : '';
  return getConfig(srcPath).then((function(_this) {
    return function(config) {
      config.sourePath = sourePath;
      requirejs.setConfig(config);
      pack.setConfig(config);
      return config;
    };
  })(this));
};


/*
 * 执行初始化任务
 * @example
 *     gulp init --path=path
 */

gulp.task('init', function() {
  var sourePath;
  sourePath = argv.path;
  if (!sourePath) {
    throw new Error('init task: path is null');
  }
  return getConfig().then(function(config) {
    config.sourePath = sourePath;
    requirejs.setConfig(config);
    return FS.makeTree(path.join(sourePath, config.pack)).then(function() {
      return FS.makeTree(path.join(sourePath, config.sass));
    }).then(function() {
      return FS.makeTree(path.join(sourePath, config.tpl));
    }).then(function() {
      return FS.copy(path.join(__dirname, 'gis.json'), path.join(sourePath, 'gis.json'));
    }).then(function() {
      return requirejs.writeConfigFile();
    });
  });
});

gulp.task('rebuild', function() {
  var sourePath;
  sourePath = argv.path;
  if (!sourePath) {
    throw new Error('init task: path is null');
  }
  return initTask(sourePath).then(function(config) {
    requirejs.writeConfigFile();
    packAll(config);
    if (config.tplBuild) {
      return buildAllTpl(config);
    }
  });
});

gulp.task('watch', function() {
  var sourePath;
  sourePath = argv.path;
  if (!sourePath) {
    throw new Error('init task: path is null');
  }
  return initTask(sourePath).then((function(_this) {
    return function(config) {
      var filter, packPath, tplBuildPath, tplPath;
      packPath = path.join(sourePath, config.pack, '**/src/*.js');
      filter = packFilter(config);
      if (config.browserReload) {
        browserSync.init({
          server: {
            baseDir: sourePath
          }
        });
      }
      gulp.watch(packPath, function(event) {
        var filePath;
        console.log('build pack: %s', event.path);
        filePath = path.dirname(event.path);
        return packTask(filePath, filter);
      });
      if (config.tplBuild) {
        tplPath = path.join(sourePath, config.tpl, '**/*.html');
        tplBuildPath = path.join(sourePath, config.pack, '../');
        if (!config.browserReload) {
          watchTpl(tplPath, tplBuildPath, config.browserReload);
        }
        if (config.browserReload) {
          return watchTpl(tplPath, tplBuildPath, config.browserReload).on('change', browserSync.reload);
        }
      }
    };
  })(this));
});