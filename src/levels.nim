import raylib

type
  PlantNames* = enum
    UnknownPlant = -1, Oak = 0, Sakura

  Terrain* = object
    tiles*: int = 0
    plants*: seq[PlantNames]
    cs*: array[0..5, uint8]
 
  Level* = object
    music*: string
    terrains*: seq[Terrain]
    tile*: Vector2 = Vector2()

proc initDaisy*(): Level =
  result.music = "StrangerThings.ogg"
  result.tile = Vector2(x: 42, y: 42)
  result.terrains = @[
    Terrain(
      tiles: 100,
      cs: [16, 60, 60, 80, 200, 250],
      plants: @[],
    ),
    Terrain(
      tiles: 100,
      cs: [16, 60, 160, 200, 30, 50],
      plants: @[Oak],
    ),
    Terrain(
      tiles: 100,
      cs: [50, 60, 130, 200, 80, 120],
      plants: @[],
    ),
    Terrain(
      tiles: 0,
      cs: [16, 60, 60, 90, 130, 200],
      plants: @[],
    )
  ]
    
  