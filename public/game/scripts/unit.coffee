
class Unit extends THREE.Object3D
  constructor: (state) ->
    super()

  addState: (state) ->

Loader = do ->
  loader = new THREE.JSONLoader()
  models = {}
  getModel = (path, cb) ->
    if models[path]
      return cb models[path]

    loader.load
      model: path
      callback: (geo) ->
        models[path] = geo
        getModel path, cb

  {getModel}


# export
@Unit = Unit
@Loader = Loader
