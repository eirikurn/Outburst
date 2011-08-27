class Hud
  constructor: (@socket)->
    @container = document.getElementById 'hud'
    @ammo = document.getElementById 'ammo'
    @ammoleft = document.getElementById 'ammoleft'
    @gameover = document.getElementById 'gameover'
    @score = document.getElementById 'score'
    
    @startcheck = no
    @socket.on 'start', () => @onGameStarted()
    @socket.on 'gameover', () => @onGameOver()
    
    # insert chat into container
    document.getElementById('container').appendChild @container
    
  stats:
    weapon: 0
    ammo: 0
    
  onPlayerState: (state) ->
    if @stats != state.weapon
      @ammo.style.width = (constants.WEAPONS[state.weapon].ammo * 10) + "px"
      @stats.weapon = state.weapon

    if state.ammo != @stats.ammo
      @ammoleft.style.width = (state.ammo * 10) + "px"
      @stats.ammo = state.ammo
    
  onGameStarted: () ->
    @gameover.style.display = "hidden"
    @startcheck = yes
    
  onGameOver: () ->
    @gameover.style.display = "inline"
    @gameover.innerHTML = "You lasted for " + @getTime()
    
  getTime: () ->
    diff = new Date(+new Date - @gamestart)
    sec = diff.getSeconds().toString()
    return diff.getMinutes() + ':' + if sec.length < 2 then "0" + sec else sec
    
  onFrame: () ->
    if @startcheck
      @gamestart = +new Date
      @startcheck = no
    if @gamestart
      @score.innerHTML = @getTime()
      
# export
@Hud = Hud