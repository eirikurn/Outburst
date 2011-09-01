class Text2D extends THREE.Object3D
  constructor: (text, width = 256, height = 128, @billboard = yes) ->
    super()
    @placeholder = document.createElement 'canvas'
    @placeholder.width = width
    @placeholder.height = height
        
    @context = @placeholder.getContext '2d'
    @context.font = 'bold 30px sans-serif'
    @context.fillStyle = 'rgba(0, 0, 0, 1)'
    @context.textAlign = 'center' 
    @context.fillText text, width / 2, (height / 2)
    
    sprite = new THREE.Sprite map: new THREE.Texture(@placeholder), useScreenCoordinates: no, blending: THREE.BillboardBlending
    sprite.map.needsUpdate = yes
    sprite.position.set 0, 0, 0
    sprite.position.normalize()
    @addChild sprite

# export
@Text2D = Text2D