import raylib, ../screens, std/lenientops

var
  texture = Texture2D()


proc initTitleScreen* =
    texture = loadTexture("resources/images/menu.png");

proc updateTitleScreen* =
  if isKeyPressed(Enter) or isGestureDetected(Tap):
    currentScreen = Gameplay

proc drawTitleScreen* =
  drawTexture(texture, Vector2(), 0, 1, White);

  drawText("KASAIVAL", 200, 90, 80, Maroon);
  drawText("an out of control flame trying to survive", 100, 255, 30, Maroon);

  drawText("touch anywhere to start burning", 140, 555, 30, BEIGE);

proc unloadTitleScreen* =
  discard