import
  raylib, screens, screens/gameplay, screens/title

var
  target = RenderTexture2d()
  current: Screen


proc getCurrentScreen() =
  case currentScreen
  of TitleScreen:
    current = Title()
  of GameplayScreen:
    current = Gameplay()
  else:
    discard

proc updateDrawFrame() {.cdecl.} =
  # Get the current window size
  let windowWidth = getScreenWidth()
  let windowHeight = getScreenHeight()
  # Calculate the scaling factor
  let scale = min(windowWidth / screenWidth, windowHeight / screenHeight)
  # Calculate the scaled screen size
  let width = float(screenWidth) * scale;
  let height = float(screenHeight) * scale;

  # Toggle fullscreen mode when F key is pressed
  if (isKeyPressed(F)):
    toggleFullscreen()

  # Update the virtual mouse position
  let mo = getMousePosition();
  mouse.x = (float(mo.x) - (float(windowWidth) - width) * 0.5) / scale
  mouse.y = (float(mo.y) - (float(windowHeight) - height) * 0.5) / scale

  # change screen if new current screen
  if (current.id != currentScreen):
    current.unload()
    getCurrentScreen()
    current.init()

  # update current screen
  current.update(getFrameTime())

  beginDrawing()
  clearBackground(Black)
  beginTextureMode(target)
  clearBackground(Black)
  # draw current screen
  current.draw()

  endTextureMode()

  let textureRect = Rectangle( x: 0, y: 0, width: float(target.texture.width), height: float(-target.texture.height))
  let screenRect = Rectangle( x: (float(windowWidth) - width) * 0.5, y: (float(windowHeight) - height) * 0.5, width: width, height: height)
  drawTexture(target.texture, textureRect, screenRect, Vector2( x: 0, y: 0 ), 0.0, WHITE)

  endDrawing()

proc main =
  # init raylib window
  setconfigFlags(flags(WindowResizable));
  initWindow(screenWidth, screenHeight, "Kasaival")
  setTargetFPS(60)
  initAudioDevice()
  
  target = loadRenderTexture(screenWidth, screenHeight)

  try:    
    # init current screen
    getCurrentScreen()
    current.init()

    # run game loop
    when defined(emscripten):
      emscriptenSetMainLoop(updateDrawFrame, 60, 1)
    else:
      setTargetFPS(60)
      while not windowShouldClose():
        updateDrawFrame()
      
    # deinit current screen
    current.unload()
  
  # close current window
  finally:
    closeAudioDevice()
    closeWindow()

main()
