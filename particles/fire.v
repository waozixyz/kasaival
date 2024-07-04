module particles

import irishgreencitrus.raylibv as vraylib
import rand

struct Particle {
pub mut:
	y f32
mut:
	position      vraylib.Vector2
	lifetime      int
	vel_start     vraylib.Vector2
	vel_end       vraylib.Vector2
	color         vraylib.Color
	color_start   vraylib.Color
	color_end     vraylib.Color
	scale         f32
	shrink_factor f32
}

pub struct Fire {
	lifetime int = 60
mut:
	position vraylib.Vector2
	color    vraylib.Color
	amount   int
	radius   int
pub mut:
	scale     f32
	particles []Particle
}

fn (self &Fire) get_particle() Particle {
	mut p := Particle{}
	p.lifetime = self.lifetime
	p.position = self.position
	vel_x := rand.int_in_range(-3, 3) or {0}
	p.vel_start = vraylib.Vector2{vel_x, -3}
	p.vel_end = vraylib.Vector2{f32(rand.int_in_range(-vel_x - 2, -vel_x + 2) or {0}) * 1.6, -3}
	p.color_start = self.color
	p.color_end = vraylib.Color{0, 30, 20, 0}
	p.color = p.color_start
	p.scale = self.scale
	p.shrink_factor = rand.f32_in_range(0.95, .99) or {0}
	// the start y, used for z sorting
	p.y = self.position.y + f32(self.radius) * .8 * self.scale
	return p
}

pub fn (mut self Fire) load() {
	self.radius = 48
	self.color = vraylib.Color{180, 30, 40, 200}
	self.amount = self.lifetime
	self.scale = .7
}

pub fn (self &Fire) get_dimensions() (f32, f32) {
	return self.radius * self.scale, self.radius * self.scale
}

pub fn (mut self Fire) update(x f32, y f32) {
	self.position.x, self.position.y = x, y
	if self.particles.len < self.amount {
		self.particles << self.get_particle()
	}
	for i, mut p in self.particles {
		if p.lifetime == 0 {
			self.particles[i] = self.get_particle()
		}
		pp := f32(p.lifetime) / self.lifetime
		if p.lifetime < self.lifetime {
			p.position.x += p.vel_start.x * pp + p.vel_end.x * (1 - pp)
			p.position.y += p.vel_start.y * pp + p.vel_end.y * (1 - pp)
		}
		// println(p.positon['x'])

		p.color.r = u8(p.color_start.r * pp + p.color_end.r * (1 - pp))
		p.color.g = u8(p.color_start.g * pp + p.color_end.g * (1 - pp))
		p.color.b = u8(p.color_start.b * pp + p.color_end.b * (1 - pp))
		p.color.a = u8(p.color_start.a * pp + p.color_end.a * (1 - pp))

		p.scale *= p.shrink_factor
		p.lifetime--
	}
}

pub fn (self &Fire) draw(i int) {
	p := self.particles[i]
	x := p.position.x - self.radius * p.scale * .5
	vraylib.draw_circle(int(x), int(p.position.y), self.radius * p.scale, p.color)
}

pub fn (self &Fire) unload() {
}
