## gis ( 前端构建工具 )

> 单页应用的前端构建工具

[![npm version](https://badge.fury.io/js/gis.svg)](https://badge.fury.io/js/gis)

## gis 简介

gis 是一整套完整，系统的[前端集成解决方案](https://en.wikipedia.org/wiki/Enterprise_application_integration)，主要应用于前端单页应用开发。

## 功能概述

* 跨平台支持win、mac、linux等系统
* 内置规范灵活，可支持一定的配置
* 动态生成 RequireJS 配置，无需手动操作
* 支持 Javascript, html 打包，包括编译, 合并，压缩和文件名 md5
* 支持 roadMap 配置，编译过程可自动排除不需要打包的文件
* 可配置自动调用浏览器以及刷新操作

## 安装

```
	npm install gis -g
```

## DEMO

**[gis-demo](https://github.com/JackieLin/gis-demo)**

## 如何使用

### 1. 建立目录
建立项目目录，同时跳转到项目目录

### 2. 初始化项目目录
项目目录下输入: 

```
	gis init
```

进行环境的初始化工作，已经建立过项目的可以跳过这一步

### 3. 重新构建项目
项目目录下输入: 

```
	gis rebuild
```

就可以重新编译整个项目，需要重新编译的时候使用

### 4. 监听目录变化
项目目录下输入: 

```
	gis watch
```

就可以监听 Javascript, html 文件变化并重新构建

## 配置
项目初始化之后，```gis.json``` 就是 **gis** 的配置文件

### pack ( 默认值: ./js/pack )
Javascript 构建目录

### roadMap ( 默认值: [])
roadMap 是一个数组，数组项需要传入对象，对象格式如下: 

```
	path: [String]: 表示需要处理的文件目录
	exclude: [Array]: 数组，需要排除合并的文件名
	
	eg: "roadMap": [{
	        "path": "./common/src",
            "exclude": ["excludefile.js"]
		}]
```

### tpl ( 默认值: ./tpl)
模板目录，编译后文件将会保存到 ```pack``` 配置对应的目录中

### tplBuild ( 默认值: true)
模板是否自动编译，单页应用推荐编译

### browserReload ( 默认值: false)
修改文件浏览器是否自动刷新

### requireConfig ( 默认值: {})
RequireJs 配置，声明会被全部复制到 ```config.js``` 文件中，详细配置查看 [RequireJs API](http://requirejs.org/)

### configFile ( 默认值: {"production": "./js/config.js", "dev": "./js/config.dev.js"})
配置生产环境和开发环境 ```RequireJs config``` 文件路径


## bug 反馈
因为 **gis** 是刚刚开发的，欢迎大家使用，有什么问题请在 [issues](https://github.com/JackieLin/gis/issues) 页面提出，希望能和大家一起交流学习

## 依赖

[Node.js](https://nodejs.org/en/)  **v5.0.0**

[gulp](http://gulpjs.com/)  **3.8**

[RequireJS](http://requirejs.org/)  **版本无限制**


## LICENSE
MIT 协议
