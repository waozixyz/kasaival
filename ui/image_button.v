module ui

import irishgreencitrus.raylibv as vraylib
import state

pub struct ImageButton {
mut:
	texture vraylib.Texture2D
	x       int
	y       int
	scale   int
}

pub fn (self &ImageButton) mouse_on_button(game_state &state.State) bool {
	w, h := self.texture.width * self.scale, self.texture.height * self.scale
	if game_state.mouse.x > self.x && game_state.mouse.x < self.x + w {
		if game_state.mouse.y > self.y && game_state.mouse.y < self.y + h {
			vraylib.set_mouse_cursor(vraylib.mouse_cursor_crosshair)
			return true
		}
	}
	return false
}

pub fn (self &ImageButton) draw(game_state &state.State) {
	vraylib.draw_texture_ex(self.texture, vraylib.Vector2{self.x + game_state.cx, self.y},
		0, self.scale, vraylib.white)
}

pub fn (self &ImageButton) unload() {
	vraylib.unload_texture(self.texture)
}
