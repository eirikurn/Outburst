class Input
  constructor: ->
    document.body.addEventListener 'keyup', (ev) => @keyup(ev)
    document.body.addEventListener 'keydown', (ev) => @keydown(ev)
    document.body.addEventListener 'mousemove', (ev) => @mousemove(ev)
    document.body.addEventListener 'mousedown', (ev) => @mousedown(ev)
    document.body.addEventListener 'mouseup', (ev) => @mouseup(ev)
  
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
    
  keydown: (event) ->
    @[@keys[event.keyCode]] = true
  
  keyup: (event) ->
    @[@keys[event.keyCode]] = false
    
  mousemove: (event) ->
    @mouse.x = event.clientX
    @mouse.y = event.clientY
    document.getElementById('mouse').innerHTML = 'X: ' + @mouse.x + ', Y: ' + @mouse.y
    
  mousedown: (event) ->
    @mouse.down = true
    
  mouseup: (event) ->
    @mouse.down = false


# export
@Input = Input