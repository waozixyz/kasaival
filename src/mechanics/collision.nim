import raylib, ../entities/player, ../world/ground, ../utils

type
  Axis = enum
    X, Y, Z

const
  BURN_TIMER_VALUE = 200

proc checkAxisCollision(playerVelocity: Vector3, playerHitbox: BoundingBox, tileHitbox: BoundingBox, axis: Axis, grounded: var bool): float =
  case axis
  of X:
    if playerVelocity.x == 0 or not (tileHitbox.min.x < playerHitbox.max.x and tileHitbox.max.x > playerHitbox.min.x):
      return playerVelocity.x
  of Y:
    if playerVelocity.y == 0:
      return playerVelocity.y
    if tileHitbox.min.y < playerHitbox.max.y:
      grounded = true
      return 0.0
    if tileHitbox.max.y > playerHitbox.min.y:
      return 0.0
  of Z:
    if playerVelocity.z == 0 or not (tileHitbox.min.z < playerHitbox.max.z and tileHitbox.max.z > playerHitbox.min.z):
      return playerVelocity.z
proc checkTileCollision*(player: Player, ground: Ground, dt: float) =
  player.updateVelocity(dt)
  var playerVelocity = player.velocity
  var tmpVel = playerVelocity
  tmpVel.y = 0
  let
    playerHitbox = getBoundingBox(player.position, player.radius)
    playerVelocityHitbox = getBoundingBox(addVectors(player.position, tmpVel), player.radius)
    playerVelocityHeightHitbox = getBoundingBox(addVectors(player.position, playerVelocity), player.radius)
  var grounded = false
  for tile in ground.tiles.mitems():
    let tileHitbox = getBoundingBox(tile.position, tile.size * 0.6)

    if checkCollisionBoxes(playerVelocityHeightHitbox, tileHitbox):
      tile.burnTimer = BURN_TIMER_VALUE
      playerVelocity.y = checkAxisCollision(playerVelocity, playerHitbox, tileHitbox, Y, grounded)

    if checkCollisionBoxes(playerVelocityHitbox, tileHitbox):
      tile.burnTimer = BURN_TIMER_VALUE
      playerVelocity.x = checkAxisCollision(playerVelocity, playerHitbox, tileHitbox, X, grounded)
      playerVelocity.z = checkAxisCollision(playerVelocity, playerHitbox, tileHitbox, Z, grounded)
      if playerVelocity.y <= 0:
        playerVelocity.y += 2
      
  player.velocity = playerVelocity
  player.state = if grounded: Grounded else: Falling