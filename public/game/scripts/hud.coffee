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

  gamestart: +new Date
    
  onPlayerState: (state) ->
    if @stats != state.weapon
      @ammo.style.width = (constants.WEAPONS[state.weapon].ammo * 10) + "px"
      @stats.weapon = state.weapon

    if state.ammo != @stats.ammo
      @ammoleft.style.width = (state.ammo * 10) + "px"
      @stats.ammo = state.ammo
    
  onGameStarted: () ->
    @gameover.style.display = "none"
    @gameover.innerHTML = ""
    @startcheck = yes
    
  onGameOver: () ->
    @gameover.style.display = "inline"
    p = document.createElement 'p'
    p.innerText = "You defended the sheeps for " + @getTime()
    @gameover.appendChild p
    
    a = document.createElement 'a'
    a.className = 'twitter-share-button'
    a.dataset["text"] = "I defended my sheeps from the killer robots for " + @getTime() + " in @outburstgame"
    a.dataset["count"] = "vertical"
    a.innerText = "Tweet" 
    po = document.createElement('script')
    po.type = 'text/javascript'
    po.async = true
    po.src = 'http://platform.twitter.com/widgets.js'
    s = document.getElementsByTagName('script')[0]
    s.parentNode.insertBefore po, s
    @gameover.appendChild a
    
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