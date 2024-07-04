module state

import irishgreencitrus.raylibv as vraylib

pub interface Screen {
	mut:
	load(mut State)
	update(mut State)
	draw(&State)
	unload()
}

pub struct State {
pub mut:
	screen  Screen
	exit    bool
	mute    bool
	pause   bool
	start_x int = -100
	cx      f32
	gw      f32 = 1000
	gh      f32 = 400
	score   int
	mouse   vraylib.Vector2
}

pub fn (mut game_state State) set_screen(screen &Screen) {
	game_state.cx = 0
	game_state.screen.unload()
	game_state.screen = Screen(screen)
	game_state.screen.load(mut game_state)
}
