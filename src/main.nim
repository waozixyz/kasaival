import
  raylib, screens, screens/gameplay, screens/title

var
  camera = Camera2D()
  target = RenderTexture2d()
  current = currentScreen

proc findMin(x: float, y: float): float =  
  if x < y:
    return x  
  else:
    return y


proc initScreen =
    case current
    of Title:
      initTitleScreen()
    of Gameplay:
      initGameplayScreen()
    else:
      discard

proc updateScreen =
  case current
    of Title:
      updateTitleScreen()
    of Gameplay:
      updateGameplayScreen()
    else:
      discard

proc drawScreen =
  case current
    of Title:
      drawTitleScreen()
    of Gameplay:
      drawGameplayScreen()
    else:
      discard

proc unloadScreen =
    case current
    of Title:
      unloadTitleScreen()
    of Gameplay:
      unloadGameplayScreen()
    else:
      discard

proc updateDrawFrame {.cdecl.} =
  # Get the current window size
  let windowWidth = getScreenWidth()
  let windowHeight = getScreenHeight()
  # Calculate the scaling factor
  let scale = findMin(windowWidth / screenWidth, windowHeight / screenHeight)
  # Calculate the scaled screen size
  let width = float(screenWidth) * scale;
  let height = float(screenHeight) * scale;

  # Toggle fullscreen mode when F key is pressed
  if (isKeyPressed(KeyboardKey(F))):
    toggleFullscreen()
  
  # Update the camera target and zoom
  camera.target.x = cx
  camera.zoom = zoom

  # Update the virtual mouse position
  let mo = getMousePosition();
  mouse.x = (float(mo.x) - (float(window_width) - width) * 0.5) / scale
  mouse.y = (float(mo.y) - (float(window_height) - height) * 0.5) / scale

  # update current screen
  if (current != currentScreen):
    unloadScreen()
    current = currentScreen
    initScreen()
  updateScreen()

  
  beginDrawing()
  clearBackground(RayWhite)
  # draw current screen
  drawScreen()

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
    initScreen()
    
    # run game loop
    when defined(emscripten):
      emscriptenSetMainLoop(updateDrawFrame, 60, 1)
    else:
      setTargetFPS(60)
      while not windowShouldClose():
        updateDrawFrame()
      
    # deinit current screen
    unloadScreen()
  
  # close current window
  finally:
    closeAudioDevice()
    closeWindow()

main()
