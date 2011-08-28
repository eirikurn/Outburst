class AnimatedMesh extends THREE.Mesh
  constructor: (geometry, materials, @animations) ->
    super geometry, materials
  
  playAnimation: (animationName) ->
    throw "'#{animationName}' animation does not exist." if animationName not of @animations
    # Reset the current morph target
    @morphTargetInfluences[ @lastKeyframe ] = 0 if @lastKeyframe
    @morphTargetInfluences[0] = 1
    # Init
    @currentAnimation = @animations[animationName]
    @interpolation = @currentAnimation.duration / @currentAnimation.keyframes
    
    @time = @currentAnimation.duration / @currentAnimation.keyframes
    @currentKeyframe = @lastKeyframe = @currentAnimation.firstKeyframeIndex
    @isPaused = no
    
  updateAnimation: (delta) ->
    if not @currentAnimation or @isPaused then return
    @time = (@time + delta * 1000) % @currentAnimation.duration
    keyframe = @currentAnimation.firstKeyframeIndex + Math.floor( @time / @interpolation )
    
    if keyframe != @currentKeyframe
      @morphTargetInfluences[ @lastKeyframe ] = 0
      @morphTargetInfluences[ @currentKeyframe ] = 1
      @morphTargetInfluences[ keyframe ] = 0
      @lastKeyframe = @currentKeyframe
      @currentKeyframe = keyframe
    
    console.log "--"
    for mkeyframe in @morphTargetInfluences
      console.log "F: " + mkeyframe
    
      
    @morphTargetInfluences[ keyframe ] = ( @time % @interpolation ) / @interpolation
    @morphTargetInfluences[ @lastKeyframe ] = 1 - @morphTargetInfluences[ keyframe ]

# export
@AnimatedMesh = AnimatedMesh