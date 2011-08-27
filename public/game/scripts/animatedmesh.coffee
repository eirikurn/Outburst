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
    @lastKeyframe = @currentKeyframe = @currentAnimation.firstKeyframeIndex
    @isPaused = no
    @time = 0
    
  updateAnimation: (delta) ->
    if not @currentAnimation or @isPaused then return
    @time = (@time + delta * 1000) % @currentAnimation.duration
    keyframe = @currentAnimation.firstKeyframeIndex + Math.floor( @time / @interpolation ) + 1
    if keyframe != @currentKeyframe
      @morphTargetInfluences[ @lastKeyframe ] = 0
      @morphTargetInfluences[ @currentKeyframe ] = 1
      @morphTargetInfluences[ keyframe ] = 0
      @lastKeyframe = @currentKeyframe
      @currentKeyframe = keyframe
      
    @morphTargetInfluences[ keyframe ] = ( @time % @interpolation ) / @interpolation
    @morphTargetInfluences[ @lastKeyframe ] = 1 - @morphTargetInfluences[ keyframe ]

# export
@AnimatedMesh = AnimatedMesh