# `#!/usr/bin/env node`

'use strict'
path = require 'path'
# 进程信息
spawn = require('child_process').spawn
# 当前路径
sourePath = process.cwd()

# 参数
argv = require('yargs').argv
_ = argv._
proc

# 初始化目录信息
if 'init' in _
    proc = spawn 'gulp', ['init', '--path=' + sourePath], 
            cwd: __dirname
            stdio: 'inherit'

else if 'rebuild' in _
    # 重新构建项目
    proc = spawn 'gulp', ['rebuild', '--path=' + sourePath],
        cwd: __dirname
        stdio: 'inherit'

else if 'test' in _
    # 重新构建项目
    proc = spawn 'gulp', ['test', '--path=' + sourePath],
        cwd: __dirname
        stdio: 'inherit'

else if 'product' in _
    # 重新构建项目
    proc = spawn 'gulp', ['product', '--path=' + sourePath],
        cwd: __dirname
        stdio: 'inherit'

else
    # 默认情况
    proc = spawn 'gulp', ['watch', '--path=' + sourePath],
        cwd: __dirname
        stdio: 'inherit'


# 输出信息和错误信息
# if proc
#     proc.stdout.on 'data', (data)->
#         console.log data.toString()

#     proc.stderr.on 'data', (data)->
#         console.log data.toString()
