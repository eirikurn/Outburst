class Hud
  constructor: (@socket)->
    @container = document.getElementById 'hud'
    @ammo = document.getElementById 'ammo'
    @ammoleft = document.getElementById 'ammoleft'
    
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
    
# export
@Hud = Hud