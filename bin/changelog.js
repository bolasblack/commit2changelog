#!/usr/bin/env node

var sysPath = require('path')
var fs = require('fs')

var libPath = sysPath.join(sysPath.dirname(fs.realpathSync(__filename)), '..', 'lib')
if (!fs.existsSync(libPath)) {
  console.log('Package broken, please reinstall and try again.');
  process.exit(1)
}

require(libPath).run()

