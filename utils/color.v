module utils

import rand
import irishgreencitrus.raylibv as vraylib

pub fn get_color(cs []int) vraylib.Color {
	grv := rand.int_in_range
	r := grv(cs[0], cs[1]) or {cs[0]}
	g := grv(cs[2], cs[3]) or {cs[2]}
	b := grv(cs[4], cs[5]) or {cs[4]}
	return vraylib.Color{u8(r), u8(g), u8(b), 255}
}
