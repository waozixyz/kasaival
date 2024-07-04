module scenery

import irishgreencitrus.raylibv as vraylib
import lyra
import state

struct Item {
mut:
	texture vraylib.Texture2D
	cx      f32
	x       int
	y       int
	layer   int
}

pub struct Background {
mut:
	items []Item
}

pub fn (mut self Background) add(texture vraylib.Texture2D, cx f32, x int, y int) {
	self.items << Item{texture, cx, x, y, 0}
}

pub fn (mut self Background) update(game_state &state.State) {
}

pub fn (self Background) draw(game_state &state.State) {
	for item in self.items {
		scale := f32(lyra.start_y) / item.texture.height
		x := item.x + game_state.cx * item.cx - item.texture.width * scale
		vraylib.draw_texture_ex(item.texture, vraylib.Vector2{x, item.y}, 0, scale, vraylib.white)
	}
}

pub fn (self &Background) unload() {
	for item in self.items {
		vraylib.unload_texture(item.texture)
	}
}
