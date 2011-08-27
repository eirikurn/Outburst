((exports)->

  exports.test = "foobar"

)(if exports? then exports else window["utils"] = {})
