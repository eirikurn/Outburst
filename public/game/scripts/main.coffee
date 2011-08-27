require = (module) ->
  match = /^(\.\/)?(.+)$/.exec m
  module = match[2].split '/'
  obj = window
  obj = obj[stub] for stub in module
  return obj

window.socket = io.connect()
window.socket.on 'welcome', (data) ->
  console.log data
  
stats = new Stats()
last = +new Date
animloop = ->
  now = +new Date
  delta = (now - last) / 1000.0
  last = now
  requestAnimFrame(animloop, world.container)
  
  world.update(delta)
  world.render()
  stats.update()
    
document.addEventListener 'DOMContentLoaded', ->
  window.input = new Input()
  window.world = new World()
  animloop()
  
  # show stats
  stats.domElement.style.position = 'absolute'
  stats.domElement.style.top = '0px'
  stats.domElement.style.zIndex = 100
  document.getElementById('container').appendChild(stats.domElement)
  
trace = (message) ->
  console?.log message
