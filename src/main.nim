import
  raylib, screens, screens/arcade, screens/title, state

const
  TARGET_FPS = 60

var
  target = RenderTexture2d()
  current: Screen

proc getCurrentScreen() =
  case gCurrentScreen
  of TitleScreen:
    current = Title()
  of ArcadeScreen:
    current = Arcade()
  else:
    discard

proc computeScale(windowWidth: int, windowHeight: int): float =
  return min(windowWidth / screenWidth, windowHeight / screenHeight)

proc updateMousePosition(windowWidth: int, windowHeight: int, scale: float) =
  let mo = getMousePosition()
  gMousePosition.x = (float(mo.x) - (float(windowWidth) - float(screenWidth) * scale) * 0.5) / scale
  gMousePosition.y = (float(mo.y) - (float(windowHeight) - float(screenHeight) * scale) * 0.5) / scale

proc updateDrawFrame() {.cdecl.} =
  let windowWidth = getScreenWidth()
  let windowHeight = getScreenHeight()
  let scale = computeScale(windowWidth, windowHeight)

  if isKeyPressed(F):
    toggleFullscreen()

  updateMousePosition(windowWidth, windowHeight, scale)

  if current.id != gCurrentScreen:
    current.unload()
    getCurrentScreen()
    current.init()

  gMouseCursor = 0
  current.update(getFrameTime())

  beginDrawing()
  clearBackground(Black)
  beginTextureMode(target)
  clearBackground(Black)
  current.draw()
  setMouseCursor(MouseCursor(gMouseCursor))
  endTextureMode()

  let textureRect = Rectangle(x: 0, y: 0, width: float(target.texture.width), height: float(-target.texture.height))
  let screenRect = Rectangle(x: (float(windowWidth) - float(screenWidth) * scale) * 0.5, y: (float(windowHeight) - float(screenHeight) * scale) * 0.5, width: float(screenWidth) * scale, height: float(screenHeight) * scale)
  
  drawTexture(target.texture, textureRect, screenRect, Vector2(x: 0, y: 0), 0.0, WHITE)
  endDrawing()

proc main() =
  setconfigFlags(flags(WindowResizable))
  initWindow(screenWidth, screenHeight, "Kasaival")
  
  target = loadRenderTexture(screenWidth, screenHeight)

  try:    
    when not defined(emscripten):
      initAudioDevice()

    getCurrentScreen()
    current.init()

    when defined(emscripten):
      emscriptenSetMainLoop(updateDrawFrame, 0, 1)
    else:
      setTargetFPS(TARGET_FPS)
      while not windowShouldClose():
        updateDrawFrame()
      
    current.unload()
  
  finally:
    closeAudioDevice()
    closeWindow()

main()
