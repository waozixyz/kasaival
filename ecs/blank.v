module ecs

import state

pub struct Blank {
mut:
	y      f32
	dead   bool
	points int
}

pub fn (self &Blank) load(x int, y int) {}

pub fn (mut self Blank) update(mut game_state state.State) {
}

pub fn (self &Blank) draw(game_state &state.State) {}

pub fn (self &Blank) unload() {
}

pub fn (mut self Blank) collided(element string, dp f32) {
}

pub fn (self &Blank) get_hitbox() []f32 {
	return [f32(0), f32(0), f32(0), f32(0)]
}
