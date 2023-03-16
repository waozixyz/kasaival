import raylib, ../screens, ../player, ../gaia/ground, ../levels, ../utils, ../gaia/sky, ../gaia/plant, std/algorithm, ../ui/hud

type
  Entity = object
    item: string
    index: array[0..1, int]
    z: float
  Arcade* = ref object of Screen
    camera: Camera2D = Camera2D()
    player: Player = Player()
    ground: Ground = Ground()
    level: Level = initDaisy()
    sky: Sky = Sky()
    music: Music
    hud: Hud = Hud()
    entities: seq[Entity]

method init*(self: Arcade) =
  self.id = ArcadeScreen
  # init music
  self.music = loadMusicStream("resources/music/" & self.level.music)
  playMusicStream(self.music);
  # init ui
  self.hud.init()
  # Init gaia
  self.sky.init()
  self.ground.init(self.level)
  # Init entities  
  self.player.init()

proc checkTileCollision(self: Arcade) =
  # check tile collision with player
  var pos = self.player.position
  var pr = self.player.getRadius() 

  # Iterate through visible tiles and check for collision with the player
  for i, tile in self.ground.tiles:
    if not isTileVisible(tile): continue

    let vertices = tile.vertices
    
    let (minX, maxX) = getMinMax(vertices, 0)
    let (minY, maxY) = getMinMax(vertices, 1)

    if pos.x - pr * 1.5 < maxX and pos.x + pr * 0.5 > minX and pos.y - pr < maxY and pos.y + pr > minY:
      # Set burn timer for tile if player collides with it
      self.ground.tiles[i].burnTimer = 2
      if tile.plants.len == 0: continue
      for j, p in tile.plants:
        self.ground.tiles[i].plants[j].burnTimer = 2

proc sortEntities(x, y: Entity): int =
  cmp(x.z, y.z)

method update*(self: Arcade, dt: float) =
  if isKeyPressed(M):
    isMute = not isMute

  if not isMute:
    updateMusicStream(self.music)

  # change screen on escape button
  if isKeyPressed(Escape):
    currentScreen = TitleScreen

  # Update the camera target and zoom
  self.camera.target.x = cx
  self.camera.zoom = zoom

  # update ui
  self.hud.update(dt)

  # Update gaia
  self.sky.update(dt)
  self.ground.update(dt)
  self.checkTileCollision()

  # Update entities
  self.player.update()

  # add entities to sort
  self.entities = @[]
  for i, t in self.ground.tiles:
    for j, p in t.plants:
      if p.dead: break
      if p.rightBound < cx or p.leftBound > cx + screenWidth: continue
      self.entities.add(Entity(index: [i, j], z: p.getZ(), item: "plant"))

  for i, p in self.player.sprite.particles:
    self.entities.add(Entity(index: [i, -1], z: p.startY + self.player.getRadius() * 0.5, item: "player"))
  self.entities.sort(sortEntities)


method draw*(self: Arcade) =
  # draw background
  self.sky.draw()

  beginMode2D(self.camera);
  # draw gaia
  self.ground.draw()

  # draw entities
  for entity in self.entities:
    var i = entity.index
    case entity.item:
      of "plant":
        self.ground.tiles[i[0]].plants[i[1]].draw()
      of "player":
        self.player.draw(i[0])
  endMode2D();
  
  # draw ui
  self.hud.draw()

method unload*(self: Arcade) =
  discard
