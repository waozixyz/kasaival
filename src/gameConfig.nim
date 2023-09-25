const
  ASSET_FOLDER* = "resources"

when defined(GraphicsApiOpenGl33):
  const
    glslVersion* = 330
else:
  const
    glslVersion* = 100
    
const
  screenWidth* = 800
  screenHeight* = 600
  startFuel* = 200
  gravity* = 9.81
  tileSize* = 22
