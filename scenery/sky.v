module scenery

import irishgreencitrus.raylibv as vraylib
import state
import lyra
import rand

struct Star {
mut:
	elapsed f32
	time    f32
	x       int
	y       int
	r       int
	pc      vraylib.Color
	nc      vraylib.Color
}

pub struct Sky {
mut:
	nebula vraylib.Texture2D
	bg     []vraylib.Texture2D
	stars  []Star
}

fn rand_u8(a int, n int) u8 {
	return u8(a + rand.intn(n) or {0})
}

fn star_color() vraylib.Color {
	return vraylib.Color{rand_u8(200, 50), rand_u8(150, 50), rand_u8(90, 50), 255}
}

pub fn (mut self Sky) load() {
	self.bg << vraylib.load_texture('resources/sky/planets.jpg'.str)
	self.nebula = vraylib.load_texture('resources/sky/nebula.png'.str)
	for i := 0; i < 100; i++ {
		x := rand.intn(lyra.game_width) or {20}
		y := rand.intn(lyra.game_height) or {20}
		mut r := rand.int_in_range(4, 15) or {12}
		c := star_color()
		if i == 80 {
			r = 50
		}
		if i == 20 {
			r = 150
		}
		time := f32(.5)
		elapsed := rand.f32n(.5) or {0}
		self.stars << Star{elapsed, time, x, y, r, c, star_color()}
	}
}

fn (star &Star) get_current_color(rat f32) vraylib.Color {
	pc := star.pc
	nc := star.nc
	r := pc.r * (1 - rat) + nc.r * rat
	g := pc.g * (1 - rat) + nc.g * rat
	b := pc.b * (1 - rat) + nc.b * rat
	return vraylib.Color{u8(r), u8(g), u8(b), 245}
}

pub fn (mut self Sky) update(game_state &state.State) {
	for mut star in self.stars {
		star.elapsed += vraylib.get_frame_time()
		if star.elapsed > star.time {
			star.pc = star.nc
			star.nc = star_color()
			star.elapsed = 0
			star.y--
			star.x += rand.int_in_range(-2, 2) or {0}
			if star.y + star.r < 0 {
				star.y += lyra.game_height
			}
		}
	}
}

pub fn (self &Sky) draw(game_state &state.State) {
	for bg in self.bg {
		vraylib.draw_texture(bg, int(game_state.cx), 0, vraylib.white)
	}
	for star in self.stars {
		r := star.elapsed / star.time
		c := star.get_current_color(r)

		vraylib.draw_circle(star.x + int(game_state.cx), star.y, star.r, c)
	}
	vraylib.draw_texture(self.nebula, int(game_state.cx), 0, vraylib.white)
}

pub fn (self &Sky) unload() {
	for bg in self.bg {
		vraylib.unload_texture(bg)
	}
	vraylib.unload_texture(self.nebula)
}
