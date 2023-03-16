import raylib

type
  PlantNames* = enum
    UnknownPlant = -1, Oak = 0, Sakura

  Terrain* = object
    tiles*: int = 0
    cs*: array[0..5, float]
 
  Level* = object
    music*: string
    terrains*: seq[Terrain]
    tile*: Vector2 = Vector2()
    grow*: seq[PlantNames]

proc initDaisy*(): Level =
  result.music = "StrangerThings.ogg"
  result.tile = Vector2(x: 42, y: 42)
  result.grow = @[Oak]

  result.terrains = @[
    Terrain(
      tiles: 100,
      cs: [16, 60, 60, 80, 200, 250],
    ),
    Terrain(
      tiles: 100,
      cs: [16, 60, 160, 200, 30, 50],
    ),
    Terrain(
      tiles: 100,
      cs: [50, 60, 130, 200, 80, 120],
    ),
    Terrain(
      tiles: 0,
      cs: [16, 60, 60, 90, 130, 200],
    )
  ]
    
  