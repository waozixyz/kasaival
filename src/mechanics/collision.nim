import raylib, ../player, ../gaia/ground, ../gameState, ../utils

type
  Axis = enum
    X, Y, Z

const
  BURN_TIMER_VALUE = 200
  COLOR_THRESHOLD_1 = 120
  COLOR_THRESHOLD_2 = 140
  COLOR_THRESHOLD_3 = 180

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
  var playerVelocity = player.getVelocity(dt)
  var tmpVel = playerVelocity
  tmpVel.y = 0
  let
    playerHitbox = getBoundingBox(player.position, player.radius)
    playerVelocityHitbox = getBoundingBox(addVectors(player.position, tmpVel), player.radius)
    playerVelocityHeightHitbox = getBoundingBox(addVectors(player.position, playerVelocity), player.radius)
  var grounded = false
  for x in 0..ground.map.len - 1:
    if not ground.isTileVisible(x): continue
    for y in 0..ground.map[x].len - 1:
      for z in 0..ground.map[x][y].len - 1:
        var tile = ground.map[x][y][z]
        let tileHitbox = getBoundingBox(tile.position, tile.size * 0.6)
        
        if checkCollisionBoxes(playerHitbox, tileHitbox):
          grounded = true
          tile.burnTimer = 200
          echo("hello")
          gPlayerFuel += (tile.fertility / 100) * 0.1
          var bf = 1.0
          if tile.color[2] > COLOR_THRESHOLD_1:
            bf *= 2.0
          if tile.color[2] > COLOR_THRESHOLD_2:
            bf *= 4.0
          if tile.color[2] > COLOR_THRESHOLD_3:
            bf *= 8.0
          #self.ground.map[x][y][z] = tile
          # gPlayerFuel -= (tile.color[2] / 255) * 0.1 * bf
          #self.ground.tiles[i].plant.burnTimer = 2
        if checkCollisionBoxes(playerVelocityHitbox, tileHitbox):
          echo("weloy")
          tile.burnTimer = BURN_TIMER_VALUE
          playerVelocity.x = checkAxisCollision(playerVelocity, playerHitbox, tileHitbox, X, grounded)
          playerVelocity.z = checkAxisCollision(playerVelocity, playerHitbox, tileHitbox, Z, grounded)
        if checkCollisionBoxes(playerVelocityHeightHitbox, tileHitbox):
          tile.burnTimer = BURN_TIMER_VALUE
          playerVelocity.y = checkAxisCollision(playerVelocity, playerHitbox, tileHitbox, Y, grounded)
        ground.map[x][y][z] = tile
      
  player.velocity = playerVelocity
  player.state = if grounded: Grounded else: Falling