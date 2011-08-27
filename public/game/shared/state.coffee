((exports)->

  class exports.UnitState
    constructor: (data) ->
      for k in @constructor.fields
        @[k] = data[k]

    fields = ['x', 'y']


)(if exports? then exports else window["state"] = {})
