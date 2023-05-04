type
  PlantNames* = enum
    UnknownPlant = -1, Oak = 0, Sakura

  Terrain* = object
    tiles*: int = 0
    cs*: array[0..5, float]
 
  Level* = object
    music*: string
    terrains*: seq[Terrain]
    tileSize*: float = 0.0
    grow*: seq[PlantNames]

proc initDaisy*(): Level =
  result.music = "StrangerThings.ogg"
  result.tileSize = 32.0
  result.grow = @[Oak]

  result.terrains = @[
    Terrain(
      tiles: 100,
      cs: [16, 60, 60, 80, 200, 250],
    ),
    Terrain(
      tiles: 100,
      cs: [16, 80, 160, 200, 30, 50],
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
    
  