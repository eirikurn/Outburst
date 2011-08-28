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
  class exports.DeltaCompressor

    type: (o) -> objToString.call o

    getDelta: (json, old) ->
      delta = {}
      changed = false
      for k, old_v of old
        if not json[k]?
          delta._r or= []
          delta._r.push k

      for k, new_v of json
        old_v = old[k]
        type = @type new_v

        if not old_v?
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

    applyDelta: (delta, old) ->

    compressPacket: (json) ->
      if not @lastOut
        return @lastOut = json
      [delta, changed] = @getDelta(json, @lastOut)
      @lastOut = json

      return delta

    uncompressPacket: (json) ->
      if not @lastIn
        return @lastIn = json

      json = @applyDelta json, @lastIn
      return @lastIn = json

)(if exports? then exports else window["utils"] = {})
