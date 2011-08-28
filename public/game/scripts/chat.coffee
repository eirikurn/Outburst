class Chat
  constructor: (@socket)->
    @log = document.getElementById 'chatlog'
    @input = document.getElementById 'chatinput'
    @form = document.getElementById 'chatform'
    @form.addEventListener 'submit', (ev) =>
      ev.preventDefault()
      @write(ev)
    , false
    
    @socket.on 'chat', (p) => @add(p)
    
    # insert chat into container
    document.getElementById('container').appendChild document.getElementById('chat')
    
    input.handle 13, =>
      @show()
      
    input.handle 27, =>
      @hide()
  
  show: ->
    input.keysEnabled = no
    @input.style.display = "inline"
    @input.focus()
  
  hide: ->
    input.keysEnabled = yes
    @input.style.display = "none"
    @input.value = ''
    
  add: (packets) ->
    for packet in packets
      li = document.createElement 'li'
      if packet.player == "server"
        li.innerHTML = "<em>" + packet.msg + "</em>"
      else
        li.innerHTML = packet.player + ": " + packet.msg
      @log.appendChild li
    
  write: (event) ->
    if @input.value.length > 0
      packet = [
        player: game.user.name
        msg: @input.value
      ]
      @add packet
      @socket.emit 'chat', packet
    @input.value = ''
    @hide()
    
# export
@Chat = Chat
