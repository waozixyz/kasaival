module plants

import irishgreencitrus.raylibv as rl
import math
import utils
import rand
import state
import lyra

const (
	deg_to_rad = math.pi / 180
)

struct Branch {
mut:
	deg int
	x1  f32
	y1  f32
	x2  f32
	y2  f32
	w   f32
	h   f32
	color rl.Color
}

pub struct Plant {
	element string = 'plant'
pub mut:
	left_x  f32
	right_x f32
	y       f32
mut:
	points             int = 10
	w                  int
	h                  int
	cs_branch          []int
	cs_leaf            []int
	change_color       []int
	grid               [][]Branch
	max_row            int = 8
	current_row        int
	split_chance       int   = 50
	split_angle        []int = [20, 30]
	grow_timer         int
	grow_time          int = 200
	burning            int
	burn_intensity     f32
	two_start_branches bool
	grow_to_random_row bool
	dead               bool
}

fn (mut self Plant) load(start_x int, y int) {
	self.y = y
	self.grow_timer = rand.intn(self.grow_time) or {0}
	self.grid = [][]Branch{len: self.max_row, init: []Branch{}}
	// make a start branch
	mut x := start_x
	mut start_angle := -90
	if self.two_start_branches {
		self.grid[0] << Branch{start_angle + 10, x, y, x, y - self.h, self.w, self.h, utils.get_color(self.cs_branch)}
		start_angle -= 10

		x += rand.int_in_range(10, 20) or {10}
	}
	self.grid[0] << Branch{start_angle, x, y, x, y - self.h, self.w, self.h, utils.get_color(self.cs_branch)}
	// grow to current size
	self.left_x = x
	self.right_x = x + self.w
	if self.grow_to_random_row {
		grow_to_row := rand.int_in_range(1, self.max_row) or {1}
		for _ in 1 .. grow_to_row {
			self.grow()
		}
	}
}

fn (mut self Plant) shrink() {
	for i in 0 .. self.grid[self.current_row].len {
		self.grid[self.current_row][i] = Branch{}
	}
	self.current_row--
	if self.current_row == 0 {
		self.dead = true
	}
}

fn (mut self Plant) grow() {
	// previous row
	prev_row := self.grid[self.current_row]
	for prev_branch in prev_row {
		split := rand.int_in_range(0, 100) or {20}
		px, py := prev_branch.x2, prev_branch.y2
		w, h := prev_branch.w * .9, prev_branch.h * .95
		mut degs := []int{}
		if self.split_chance > split {
			get_angle := fn (self &Plant) int {
				return rand.int_in_range(self.split_angle[0], self.split_angle[1]) or {self.split_angle[0]}
			}
			degs << prev_branch.deg - get_angle(self)
			degs << prev_branch.deg + get_angle(self)
		} else {
			degs << prev_branch.deg
		}
		for deg in degs {
			nx := int(px + math.cos(f32(deg) * plants.deg_to_rad) * h)
			ny := int(py + math.sin(f32(deg) * plants.deg_to_rad) * h)
			c := utils.get_color(self.cs_branch)
			self.grid[self.current_row + 1] << Branch{deg, px, py, nx, ny, w, h, c}
			if nx < self.left_x {
				self.left_x = nx
			} else if nx > self.right_x {
				self.right_x = nx + w
			}
		}
	}
	self.current_row++
}

fn (mut branch Branch) burn_color(self &Plant) {
	mut r, mut g, mut b := branch.color.r, branch.color.g, branch.color.b
	b = 0
	if r < 200 {
		r += u8(self.burn_intensity * 2)
	}
	if g > 100 {
		g -= 2
	}
	branch.color = rl.Color{r, g, b, 255}
}

fn (mut self Plant) collided(element string, dp f32) {
	if element == 'fire' {
		self.burning = 100
		self.burn_intensity = dp
	}
}

fn (self &Plant) get_hitbox() []f32 {
	b := self.grid[0][0]
	x1 := self.left_x
	x2 := self.right_x
	return [x1, x2, b.y2, b.y1]
}

fn (mut self Plant) update(game_state &state.State) {
    if self.burning > 0 {
        for mut row in self.grid {
            for mut branch in row {
                branch.burn_color(self)
            }
        }
        if self.current_row >= 0 {
            if self.grow_timer >= self.grow_time {
                self.shrink()
                self.grow_timer = 0
            }
            self.grow_timer += int(self.burn_intensity)
        }
    } else {
        if self.current_row < self.max_row - 1 {
            self.grow_timer--
            if self.grow_timer < 0 {
                self.grow()
                self.grow_timer = self.grow_time
            }
        }
    }
}

fn (self &Plant) get_color(c rl.Color) rl.Color {
	growth := f32(self.current_row + 1 - f32(self.grow_timer) / self.grow_time) / self.grid.len
	r := u8(c.r + self.change_color[0] * growth)
	g := u8(c.g + self.change_color[1] * growth)
	b := u8(c.b + self.change_color[2] * growth)
	return rl.Color{r, g, b, 255}
}


fn (self &Plant) draw(game_state &state.State) {
    for i, row in self.grid {
        for branch in row {
            x1, y1 := branch.x1, branch.y1
            mut x2, mut y2 := branch.x2, branch.y2
            if i == self.current_row && self.grow_timer > 0 {
                get_next_pos := fn (self &Plant, a f32, b f32) f32 {
                    return b + (a - b) * self.grow_timer / self.grow_time
                }
                x2 = get_next_pos(self, x1, x2)
                y2 = get_next_pos(self, y1, y2)
            }
            if (x1 > game_state.cx || x2 > game_state.cx)
                && (x1 < game_state.cx + lyra.game_width || x2 < game_state.cx + lyra.game_width) {
                rl.draw_line_ex(rl.Vector2{x1, y1}, rl.Vector2{x2, y2},
                    branch.w, self.get_color(branch.color))
            }
        }
    }
}

fn (self &Plant) unload() {
}
