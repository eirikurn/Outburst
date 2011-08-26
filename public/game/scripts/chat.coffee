class Chat
  constructor: (@socket)->
    @container = document.getElementById 'chat'
    @log = document.getElementById 'chatlog'
    @input = document.getElementById 'chatinput'
    @bar = document.getElementById 'chatbar'
    @form = document.getElementById 'chatform'
    @form.addEventListener 'submit', (ev) =>
      ev.preventDefault()
      @write(ev)
      false
    , false
    
    @socket.on 'chat', (p) => @add(p)
    
    # insert chat into container
    document.getElementById('container').appendChild document.getElementById('chat')
    
    toggle = =>
      if @bar.style.display == "inline"
        @hide()
      else
        @show()
        
    input.handle 13, toggle # enter
    input.handle 89, toggle # y
      
    input.handle 27, => # esc
      @hide()
  
  show: ->
    input.keysEnabled = no
    @bar.style.display = "inline"
    @input.focus()
  
  hide: ->
    @bar.style.display = "none"
    @input.value = ''
    input.keysEnabled = yes
    
  add: (packets) ->
    for packet in packets
      li = document.createElement 'li'
      if packet.player == "server"
        li.innerHTML = packet.msg
        li.className = "server"
      else
        li.innerHTML = packet.player + ": " + packet.msg
      @log.appendChild li
      
    # always scroll to bottom
    @log.scrollTop = @log.scrollHeight
    
  write: (event) ->
    if @input.value.length > 0
      packet = [
        player: game.user.username
        msg: @input.value
      ]
      @add packet
      @socket.emit 'chat', packet
    @input.value = ''
    
# export
@Chat = Chat
