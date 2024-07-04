module player

import irishgreencitrus.raylibv as vraylib
import lyra
import math
import particles
import state

pub struct Core {
pub:
	element string = 'fire'
pub mut:
	y     f32
	dp    f32 = 5
	flame particles.Fire
mut:
	x     f32
	scale f32 = 1
	hp    f32 = 100
	xp    f32
	lvl   int
	speed int = 10
	dead  bool
}

pub fn (mut self Core) load() {
	self.x = lyra.game_width * .5
	self.y = lyra.game_height * .8
	self.flame = particles.Fire{}
	self.flame.load()
}

fn is_key_down(keys []int) bool {
	mut pressed := false
	for key in keys {
		if vraylib.is_key_down(key) {
			pressed = true
		}
	}
	return pressed
}

const (
	key_right = [vraylib.key_right, vraylib.key_d]
	key_left  = [vraylib.key_left, vraylib.key_a]
	key_up    = [vraylib.key_up, vraylib.key_w]
	key_down  = [vraylib.key_down, vraylib.key_s]
)

// get move direction
fn get_direction(self &Core, game_state &state.State) (f32, f32) {
	angle := fn (dx f64, dy f64) (f64, f64) {
		mut angle := math.atan2(dx, dy)
		if angle < 0 {
			angle += math.pi * 2
		}
		return math.sin(angle), math.cos(angle)
	}
	mut dx, mut dy := 0.0, 0.0
	if is_key_down(player.key_right) {
		dx = 1
	}
	if is_key_down(player.key_left) {
		dx = -1
	}
	if is_key_down(player.key_up) {
		dy = -1
	}
	if is_key_down(player.key_down) {
		dy = 1
	}
	// check mouse press
	if vraylib.is_mouse_button_down(vraylib.mouse_button_left) {
		mut pos := game_state.mouse
		diff_x, diff_y := int(pos.x - self.x + game_state.cx), int(pos.y - self.y)
		offset := f32(self.speed) * .3
		if diff_x > offset || diff_x < -offset || diff_y > offset || diff_y < -offset {
			dx, dy = angle(diff_x, diff_y)
		}
	}
	return f32(dx), f32(dy)
}

// player update
pub fn (mut self Core) update(mut game_state state.State) {
	w, h := self.flame.get_dimensions()
	mut dx, mut dy := get_direction(self, game_state)
	dx *= self.speed
	dy *= self.speed
	eye_bound := lyra.game_width / 5

	// if in eye bounds move the screen
	if (self.x + dx < game_state.cx + eye_bound && game_state.cx > game_state.start_x)
		|| (self.x + dx > game_state.cx + lyra.game_width - eye_bound
		&& game_state.cx < game_state.gw + game_state.start_x - lyra.game_width) {
		game_state.cx = game_state.cx + dx
	}

	// otherwise move self.x and self.y
	if self.x + dx < game_state.cx + w * .5 && dx < 0 {
		self.x = game_state.cx + w * .5
	} else if self.x + dx > game_state.cx + lyra.game_width - w * .5 {
		self.x = game_state.cx + lyra.game_width - w * .5
	} else {
		self.x += dx
	}

	if self.y + dy > lyra.game_height && dy > 0 {
		self.y = lyra.game_height
	} else if self.y + dy < lyra.start_y + h * .3 && dy < 0 {
		self.y = lyra.start_y + h * .3
	} else {
		self.y += dy
	}

	self.flame.update(self.x, self.y - h)
}

pub fn (self &Core) burn(fuel f32) {
}

pub fn (self &Core) get_hitbox() []f32 {
	w, h := self.flame.get_dimensions()
	return [self.x - w, self.x, self.y - h * .7, self.y - h * .1]
}

pub fn (self &Core) draw(i int) {
	self.flame.draw(i)
}

pub fn (self &Core) unload() {
	self.flame.unload()
}
