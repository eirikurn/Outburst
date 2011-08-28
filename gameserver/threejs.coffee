
fs = require 'fs'
vm = require 'vm'

global.THREE = {}

loadThreeClass = (cls) ->
  context = THREE: global.THREE
  filename = "gameserver/three.js/#{cls}.js"
  code = fs.readFileSync filename
  vm.runInNewContext code, context, filename

loadThreeClass 'Vector2'

