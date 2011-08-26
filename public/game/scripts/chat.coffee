class Chat
  constructor: ->
    @log = document.getElementById 'chatlog'
    @input = document.getElementById 'chatinput'
    @form = document.getElementById 'chatform'
    @form.addEventListener 'submit', (ev) =>
      ev.preventDefault()
      @write(ev)
    , false
    
    # insert chat into container
    document.getElementById('container').appendChild document.getElementById('chat')
    
    input.handle 13, =>
      @show()
      
    input.handle 27, =>
      @hide()
  
  show: ->
    input.keys.enabled = no
    @input.style.display = "inline"
    @input.focus()
  
  hide: ->
    input.keys.enabled = yes
    @input.style.display = "none"
    @input.value = ''
    
  add: (message) ->
    li = document.createElement 'li'
    li.innerHTML = message
    @log.appendChild li
    
  write: (event) ->
    @add @input.value if @input.value.length > 0
    @input.value = ''
    @hide()
    
# export
@Chat = Chat
