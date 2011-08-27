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

)(if exports? then exports else window["utils"] = {})
