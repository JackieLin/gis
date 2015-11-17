#!/usr/bin/env node

'use strict';
var _, argv, path, proc, sourePath, spawn,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

path = require('path');

spawn = require('child_process').spawn;

sourePath = process.cwd();

argv = require('yargs').argv;

_ = argv._;

proc;

if (indexOf.call(_, 'init') >= 0) {
  proc = spawn('gulp', ['init', '--path=' + sourePath], {
    cwd: __dirname
  });
} else if (indexOf.call(_, 'rebuild') >= 0) {
  proc = spawn('gulp', ['rebuild', '--path=' + sourePath], {
    cwd: __dirname
  });
} else {
  proc = spawn('gulp', ['watch', '--path=' + sourePath], {
    cwd: __dirname
  });
}

if (proc) {
  proc.stdout.on('data', function(data) {
    return console.log(data.toString());
  });
  proc.stderr.on('data', function(data) {
    return console.log(data.toString());
  });
}
