module utils

import irishgreencitrus.raylibv as vraylib

pub struct Animation {
pub mut:
	state     string
	direction int
mut:
	x       f32
	y       f32
	w       int
	h       int
	counter int
	texture vraylib.Texture2D
	frame   int
	frames  [][]int
	speed   int
	pos     vraylib.Vector2
	burning bool
	states  map[string]int
}

pub fn (mut self Animation) load(mob string, states map[string]int, speed int, frame_w int, frame_h int, burn_frame int) {
	self.states = states.clone()
	self.direction = 1
	self.speed = speed
	self.texture = vraylib.load_texture(('resources/mobs/' + mob + '.png').str)
	self.frames = [][]int{}
	self.w, self.h = frame_w, frame_h
	mut x, mut y := 0, 0

	for y < self.texture.height {
		for x < self.texture.width {
			self.frames << [x, y]
			if self.frames.len == 12 {
				break
			}

			x += frame_w
		}
		x = 0
		y += frame_h
	}
}

pub fn (mut self Animation) update(x f32, y f32) {
	self.counter++
	if self.counter >= 60 / self.speed {
		self.frame++

		mut start_frame := 0
		mut state_frames := 0
		for state, frames in self.states {
			if self.state == state {
				state_frames = frames
				break
			}
			start_frame += frames
		}
		if self.frame >= start_frame + state_frames || self.frame < start_frame {
			self.frame = start_frame
		}
		self.counter = 0
	}
	self.x, self.y = x, y
}

pub fn (self &Animation) draw() {
	frame := self.frames[self.frame]
	rect := vraylib.Rectangle{frame[0], frame[1], self.w * self.direction, self.h}
	pos := vraylib.Vector2{self.x, self.y - self.h}

	vraylib.draw_texture_rec(self.texture, rect, pos, vraylib.white)
}

pub fn (self &Animation) unload() {
	vraylib.unload_texture(self.texture)
}
