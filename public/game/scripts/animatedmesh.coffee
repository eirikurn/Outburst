class AnimatedMesh extends THREE.Mesh
  constructor: (geometry, materials, @animations) ->
    super geometry, materials
  
  playAnimation: (animationName) ->
    throw "'#{animationName}' animation does not exist." if animationName not of @animations
    @resetMorphs()
    
    # Init
    @currentAnimation = @animations[animationName]
    @morphTargetInfluences[@currentAnimation.firstKeyFrameIndex] = 1
    
    @interpolation = @currentAnimation.duration / @currentAnimation.keyframes
    
    @time = @currentAnimation.duration / @currentAnimation.keyframes
    @currentKeyframe = @lastKeyframe = @currentAnimation.firstKeyframeIndex
    @isPaused = no
    
  updateAnimation: (delta) ->
    if not @currentAnimation or @isPaused then return
    # Don't update one frame animations
    if @currentAnimation.duration <= 0 or @currentAnimation.keyframes <= 1 then return
    
    @time = (@time + delta * 1000) % @currentAnimation.duration
    keyframe = @currentAnimation.firstKeyframeIndex + Math.floor( @time / @interpolation )
    
    if keyframe != @currentKeyframe
      @morphTargetInfluences[ @lastKeyframe ] = 0
      @morphTargetInfluences[ @currentKeyframe ] = 1
      @morphTargetInfluences[ keyframe ] = 0
      @lastKeyframe = @currentKeyframe
      @currentKeyframe = keyframe
      
    @morphTargetInfluences[ keyframe ] = ( @time % @interpolation ) / @interpolation
    @morphTargetInfluences[ @lastKeyframe ] = 1 - @morphTargetInfluences[ keyframe ]
  
  resetMorphs: ->
    for i in [0..@morphTargetInfluences.length]
      @morphTargetInfluences[i] = 0

# export
@AnimatedMesh = AnimatedMesh