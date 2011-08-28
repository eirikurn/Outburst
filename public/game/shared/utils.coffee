((exports)->

  # An object pool that implements a fixed sliding window.
  class exports.StatePool
    constructor: (@cls, @capacity=20) ->
      @array = new Array @capacity
      @start = 0
      @length = 0

    item: (index) ->
      index = @length + index if index < 0
      return undefined unless 0 <= index < @length
      return @array[(@start + index)%@capacity]

    new: ->
      index = (@start + @length) % @capacity
      item = @array[index]
      if item
        @start = (@start + 1) % @capacity
      else
        @array[index] = item = new @cls(false)
        @length++

      item.init.apply item, arguments
      return item

    head: -> @item -1

    tail: -> @item 0

  objToString = Object.prototype.toString

  class exports.CompressionSocket
    constructor: (@socket, messageTypes) ->
      @lastIn = {}
      @lastOut = {}
      for t in messageTypes
        @lastOut[t] = @lastIn[t] = null

      @broadcast = @socket.broadcast

    on: (type, cb) ->
      if type of @lastIn
        @socket.on type, (args...) =>
          args[0] = @uncompress(type, args[0])
          cb.apply null, args

      else
        @socket.on.apply @socket, arguments

    emit: (args...) ->
      [type, data] = args

      if type of @lastOut
        args[1] = @compress(args[0], args[1])

      @socket.emit.apply @socket, args

    # Logic
    typeOf: (o) -> objToString.call o

    getDelta: (json, old) ->
      delta = {}
      changed = false
      for k, old_v of old
        if k not of json
          delta._r or= []
          delta._r.push k

      for k, new_v of json
        old_v = old[k]
        type = @typeOf new_v

        if k not of old
          delta[k] = new_v
          changed = true

        else if type == "[object Array]"
          if new_v.length != old_v.length
            delta[k] = new_v
            changed = true

          for _, i in new_v
            if new_v[i] != old_v[i]
              delta[k] = new_v
              changed = true

        else if type == "[object Object]"
          [d, c] = @getDelta new_v, old_v
          if c
            delta[k] = d
            changed = true

        else if new_v != old_v
          delta[k] = new_v
          changed = true

      return [delta, changed]

    applyDelta: (delta, old={}) ->
      _r = delta._r

      for k in delta._r or []
        delete old[k]
      delete old._r

      for k, new_v of delta when k != '_r'
        type = @typeOf new_v

        if type == "[object Object]"
          old[k] = @applyDelta(new_v, old[k])
        else
          old[k] = new_v

      return old

    compress: (type, json) ->
      if not @lastOut[type]
        return @lastOut[type] = json
      [delta, changed] = @getDelta(json, @lastOut[type])
      @lastOut[type] = json

      return delta

    uncompress: (type, json) ->
      return @lastIn[type] = @applyDelta json, @lastIn[type]

)(if exports? then exports else window["utils"] = {})
