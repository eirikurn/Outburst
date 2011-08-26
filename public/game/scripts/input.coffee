class Input
  constructor: ->
    document.addEventListener 'keyup', (ev) => @keyup(ev)
    document.addEventListener 'keydown', (ev) => @keydown(ev)
    document.addEventListener 'mousemove', (ev) => @mousemove(ev)
    document.addEventListener 'mousedown', (ev) => @mousedown(ev)
    document.addEventListener 'mouseup', (ev) => @mouseup(ev)
    document.addEventListener 'mousewheel', (ev) => @mousescroll(ev)
    document.addEventListener 'DOMMouseScroll', (ev) => @mousescroll(ev)
    
    @windowHalfX = window.innerWidth / 2
    @windowHalfY = window.innerHeight / 2
  
  keys:
    37: 'left'
    38: 'up'
    39: 'right'
    40: 'down'
    65: 'left' # A
    87: 'up' # W
    68: 'right' # D
    83: 'down' # S
    
  mouse:
    x: 0
    y: 0
    down: false
    scroll: 0
    
  keydown: (event) ->
    @[@keys[event.keyCode]] = true
  
  keyup: (event) ->
    @[@keys[event.keyCode]] = false
    
  mousemove: (event) ->
    @mouse.x = event.clientX - @windowHalfX
    @mouse.y = -(event.clientY - @windowHalfY)
    document.getElementById('mouse').innerHTML = 'X: ' + @mouse.x + ', Y: ' + @mouse.y
    
  mousedown: (event) ->
    @mouse.down = true
    
  mouseup: (event) ->
    @mouse.down = false
  
  mousescroll: (event) ->
    @mouse.scroll += event.wheelDeltaY


# export
@Input = Input