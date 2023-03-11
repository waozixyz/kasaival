import raylib, ../screens, std/lenientops

type
  Title* = ref object of Screen
    texture = Texture2D()


method init*(self: Title) =
  self.id = TitleScreen
  self.texture = loadTexture("resources/images/menu.png");
  
method update*(self: Title, dt: float) =
  if isKeyPressed(Enter) or isGestureDetected(Tap):
    currentScreen = GameplayScreen
  discard

method draw*(self: Title)  =
  drawTexture(self.texture, Vector2(), 0, 1, White);

  drawText("KASAIVAL", 200, 90, 80, Maroon);
  drawText("an out of control flame trying to survive", 100, 255, 30, Maroon);

  drawText("touch anywhere to start burning", 140, 555, 30, BEIGE);

method unload*(self: Title) =
  discard
