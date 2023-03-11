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

proc updateDrawFrame {.cdecl.} =
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
  mouse.x = (float(mo.x) - (float(window_width) - width) * 0.5) / scale
  mouse.y = (float(mo.y) - (float(window_height) - height) * 0.5) / scale

  # change screen if new current screen
  if (current.id != currentScreen):
    current.unload()
    getCurrentScreen()
    current.init()

  # update current screen
  current.update()

  beginDrawing()
  clearBackground(Black)
  # draw current screen
  current.draw()

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
