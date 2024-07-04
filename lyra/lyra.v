module lyra

import irishgreencitrus.raylibv as vraylib
import rand

pub const (
	game_width  = 1920
	game_height = 1080
	start_y     = 540
)

pub fn get_color(cs []int) vraylib.Color {
	grv := rand.int_in_range
	r := grv(cs[0], cs[1]) or {cs[0]}
	g := grv(cs[2], cs[3]) or {cs[2]}
	b := grv(cs[4], cs[5]) or {cs[4]}
	return vraylib.Color{u8(r), u8(g), u8(b), 255}
}
