class Input
  constructor: ->
    document.body.addEventListener 'keyup', (ev) => @keyup(ev)
    document.body.addEventListener 'keydown', (ev) => @keydown(ev)
  
  keys:
    37: 'left'
    38: 'up'
    39: 'right'
    40: 'down'
    65: 'left' # A
    87: 'up' # W
    68: 'right' # D
    83: 'down' # S
    
  keydown: (event) ->
    @[@keys[event.keyCode]] = true
  
  keyup: (event) ->
    @[@keys[event.keyCode]] = false


# export
@Input = Input