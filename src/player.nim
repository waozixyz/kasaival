import raylib, screens, particles/fire, std/lists



var
  position = Vector2()
  sprite = Fire()


proc initPlayer* =
  position = Vector2(x: cx + screenWidth * 0.5, y: screenHeight * 0.8)
  sprite.init()

proc updatePlayer* =
  sprite.update(position)
  #particles.add(p)
  discard
proc drawPlayer* =
  sprite.draw()

proc unloadPlayer* =
  sprite.unload()
