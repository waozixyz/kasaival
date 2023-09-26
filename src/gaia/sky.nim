import raylib, ../state

const
  STARRY_NIGHT_SHADER_PATH = "resources/shaders/glsl330/starry_night.fs"

type
  Sky* = object
    seconds: float
    shader: Shader
    secondsLoc: ShaderLocation

method init*(self: var Sky) {.base.} =
  self.shader = loadShader("", STARRY_NIGHT_SHADER_PATH)
  
  if self.shader.id == 0:
    echo "Error: Failed to load shader!"

  self.secondsLoc = getShaderLocation(self.shader, "iTime")
  let iResolutionLoc = getShaderLocation(self.shader, "iResolution")
  let iMouseLoc = getShaderLocation(self.shader, "iMouse")

  let iResolution: array[2, float32] = [screenWidth.float32, screenHeight.float32]
  let iMouse: array[2, float32] = [0.0, 0.0]

  setShaderValue(self.shader, iResolutionLoc, iResolution)
  setShaderValue(self.shader, iMouseLoc, iMouse)

method update*(self: var Sky, dt: float) {.base.} =
  self.seconds += dt
  # TODO: Uncomment the following line if updating the shader's iTime is required.
  # setShaderValue(self.shader, self.secondsLoc, self.seconds.float32)

method draw*(self: Sky) {.base.} =
  beginShaderMode(self.shader)
  drawRectangle(Vector2(), Vector2(x: screenWidth, y: screenHeight), Black)
  endShaderMode()
