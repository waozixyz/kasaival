import raylib, ../screens, ../player

var
  camera = Camera2D()


proc initGameplayScreen* =
  initPlayer()

proc updateGameplayScreen* =
  if isKeyPressed(Escape):
    currentScreen = Title

  # Update the camera target and zoom
  camera.target.x = cx
  camera.zoom = zoom

  updatePlayer()

proc drawGameplayScreen* =
  beginMode2D(camera);
  drawPlayer()
  endMode2D();

proc unloadGameplayScreen* =
  unloadPlayer()
