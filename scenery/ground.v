module scenery

import irishgreencitrus.raylibv as vraylib
import lyra
import rand
import state

const rows = 12

struct Tile {
	p1        vraylib.Vector2
	p2        vraylib.Vector2
	p3        vraylib.Vector2
	org_color vraylib.Color
mut:
	color vraylib.Color
}

struct Section {
mut:
	grid      [][]Tile
	water     bool
	direction int
	gradient  [][]int
	tile_w    f32
	width     int
	start_x   f32
}

pub struct Ground {
mut:
	sections  []Section
	pos_y     []f32
	tile_size f32
	elapsed   f32
	tick      f32
}

fn get_color(s Section, x f32) vraylib.Color {
	gr := s.gradient
	width := s.width
	start_x := s.start_x
	mut rat := (x - start_x) / width

	rat = rat + rand.f32_in_range(-.1, .1) or {0}
	if rat < 0 {
		rat = 0
	}
	if rat > 1 {
		rat = 1
	}
	r := gr[0][0] * (1 - rat) + gr[1][0] * rat
	g := gr[0][1] * (1 - rat) + gr[1][1] * rat
	b := gr[0][2] * (1 - rat) + gr[1][2] * rat

	return vraylib.Color{u8(r), u8(g), u8(b), 255}
}

pub fn (mut self Ground) add_section(start_x f32, width int, gradient [][]int, direction int) f32 {
	mut y := lyra.start_y
	gh := lyra.game_height - y
	mut s := Section{}
	s.gradient = gradient
	s.width = width
	s.tile_w = gh / scenery.rows
	s.start_x = start_x
	s.direction = direction
	w := s.tile_w
	h := w
	self.tile_size = h
	// make the grid for this section
	mut last_x := f32(0)
	s.grid = [][]Tile{len: scenery.rows, init: []Tile{}}
	for i in 0 .. scenery.rows {
		if self.pos_y.len < scenery.rows {
			self.pos_y << y
		}
		mut x := s.start_x - w
		for x < s.start_x + width + w {
			c1 := get_color(s, x - w * .5)
			s.grid[i] << Tile{vraylib.Vector2{x - w * .5, y}, vraylib.Vector2{x, y + h}, vraylib.Vector2{
				x + w * .5, y}, c1, c1}
			c2 := get_color(s, x)
			s.grid[i] << Tile{vraylib.Vector2{x + w * .5, y}, vraylib.Vector2{x, y + h}, vraylib.Vector2{
				x + w, y + h}, c2, c2}
			x += int(w)
		}
		y += int(h)
		last_x = x + w
	}
	// check if water
	for i, g in gradient {
		if g[2] > g[0] && g[2] > g[1] {
			s.water = true
			s.direction = i
		}
	}

	self.sections << s
	return last_x
}

fn (mut tile Tile) heal() {
	mut r, mut g, mut b := tile.color.r, tile.color.g, tile.color.b
	o_r, o_g, o_b := tile.org_color.r, tile.org_color.g, tile.org_color.b

	if r != o_r {
		r--
	}
	if b != o_b {
		b++
	}
	if g != o_g {
		g++
	}
	tile.color = vraylib.Color{r, g, b, 255}
}

fn get_rgb(c vraylib.Color) (f32, f32, f32) {
	return f32(c.r), f32(c.g), f32(c.b)
}

fn (mut tile Tile) wave(c vraylib.Color) {
	mut r, mut g, mut b := get_rgb(tile.color)
	o_r, o_g, o_b := get_rgb(tile.org_color)
	n_r, n_g, n_b := get_rgb(c)
	r = (o_r + n_r) * .5
	g = (o_g + n_g) * .5
	b = (o_b + n_b) * .5
	tile.color = vraylib.Color{u8(r), u8(g), u8(b), 255}
}

pub fn (mut self Ground) update() {
	delta := vraylib.get_frame_time()
	self.elapsed += delta
	self.tick += delta

	for mut s in self.sections {
		for mut row in s.grid {
			for i, mut tile in row {
				if self.tick > 0.1 {
					tile.heal()
				}
				if s.water {
					modi := if s.direction == 0 { i + 1 } else { row.len - i + 1 }
					if int(self.elapsed * 60) % modi == 0 {
						tile.wave(get_color(s, tile.p2.x - f32(s.tile_w) * .5))
					}
				}
			}
		}
	}
	if self.tick > 0.1 {
		self.tick = 0
	}
}

fn (mut tile Tile) burn(power f32) f32 {
	dmg := power
	o_r, o_g, _ := tile.org_color.r, tile.org_color.g, tile.org_color.b

	_, t_g, _ := tile.color.r, tile.color.g, tile.color.b
	mut r, mut g, mut b := tile.color.r, tile.color.g, tile.color.b

	if g > o_g - 30 && g - u8(dmg) > 0 {
		g -= u8(dmg)
	}
	if r < o_r + 20 && r + u8(dmg) < 255 {
		r += u8(dmg)
	}
	tile.color = vraylib.Color{r, g, b, 255}
	return t_g - g - f32(b) * .05
}

fn (tile &Tile) get_lr(i int) (f32, f32) {
	mut l := f32(-1)
	if i % 2 == 0 {
		l = tile.p1.x
	} else {
		l = tile.p2.x
	}
	return l, tile.p3.x
}

pub fn (mut self Ground) collide(b []f32, element string, power f32) f32 {
	mut fuel := f32(0)
	mut index := []int{}
	for i, y in self.pos_y {
		if y < b[3] && y + self.tile_size > b[2] {
			index << i
		}
	}
	for mut section in self.sections {
		for i in index {
			for j, tile in section.grid[i] {
				l, r := tile.get_lr(j)
				if l < b[1] && r > b[0] {
					if element == 'fire' {
						fuel += section.grid[i][j].burn(power)
					}
				}
			}
		}
	}
	return fuel
}

pub fn (mut self Ground) draw(game_state &state.State) {
	for mut section in self.sections {
		for mut row in section.grid {
			for i, tile in row {
				l, r := tile.get_lr(i)
				w := r - l
				if l + w > game_state.cx && r < game_state.cx + lyra.game_width + w {
					vraylib.draw_triangle(tile.p1, tile.p2, tile.p3, tile.color)
				}
			}
		}
	}
}

pub fn (self &Ground) unload() {
}
