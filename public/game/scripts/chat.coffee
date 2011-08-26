class Chat
  constructor: (@socket)->
    @container = document.getElementById 'chat'
    @log = document.getElementById 'chatlog'
    @input = document.getElementById 'chatinput'
    @form = document.getElementById 'chatform'
    @form.addEventListener 'submit', (ev) =>
      ev.preventDefault()
      @write(ev)
      false
    , false
    
    @socket.on 'chat', (p) => @add(p)
    
    # insert chat into container
    document.getElementById('container').appendChild document.getElementById('chat')
    
    input.handle 13, =>
      if @input.style.display == "inline"
        @hide()
      else
        @show()
      
    input.handle 27, =>
      @hide()
  
  show: ->
    input.keysEnabled = no
    @input.style.display = "inline"
    @input.focus()
  
  hide: ->
    @input.style.display = "none"
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
        player: game.user.name
        msg: @input.value
      ]
      @add packet
      @socket.emit 'chat', packet
    @input.value = ''
    
# export
@Chat = Chat
