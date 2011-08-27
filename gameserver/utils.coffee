
# An object pool that implements a fixed sliding window.
class exports.RollingPool
  constructor: (@capacity=20, cls=(-> {})) ->
    @array = new Array @capacity
    @array[i] = new cls() for i in [0...capacity]
    @start = 0
    @count = 0

  item: (index) ->
    index = @count + index if index < 0
    return undefined unless 0 <= index < @count
    return @array[(@start + index)%@capacity]

  get: ->
    item = @array[(@start + @count)%@capacity]
    if @count < @capacity
      @count++
    else
      @start = (@start + 1) % @capacity

