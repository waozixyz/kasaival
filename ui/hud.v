module ui

import lyra
import irishgreencitrus.raylibv as vraylib
import state

const (
	exit_button  = 0
	pause_button = 1
	music_button = 2
)

const asset_path = 'resources/ui/'

const asset_ext = '.png'

const top_left = [['exit'], ['pause', 'resume']]

const top_right = [['music', 'no_music']]

// icon x, y, w, h
const icon_w = 128

const icon_h = 128

const start_x = 64

const start_y = 64

const icon_scale = .7

// state of button
struct ButtonState {
	texture vraylib.Texture2D
	execute fn (&state.State) = unsafe { nil }
}

// the icon / button
struct Icon {
mut:
	states []ButtonState
	state  int
	x      int
	y      int
}

// the head over display
pub struct HUD {
mut:
	key_timeout int
	icons       []Icon
}

// get the function to provoke if button activated
fn get_fn(btn string) fn (&state.State) {
    match btn {
        'exit' { return fn (mut game_state &state.State) { game_state.exit = true } }
        'pause' { return fn (mut game_state &state.State) { game_state.pause = false } }
        'resume' { return fn (mut game_state &state.State) { game_state.pause = true } }
        'music' { return fn (mut game_state &state.State) { game_state.mute = false } }
        'no_music' { return fn (mut game_state &state.State) { game_state.mute = true } }
        else { return fn (mut game_state &state.State) {} }
    }
}

// add an icon button
fn (mut self HUD) add_icon(states []string, x int, y int) {
	mut icon := Icon{}
	icon.x, icon.y = x, y
	for btn in states {
		icon.states << ButtonState{vraylib.load_texture((ui.asset_path + btn + ui.asset_ext).str), get_fn(btn)}
	}
	self.icons << icon
}

// load hud
pub fn (mut self HUD) load() {
	// top left row of icons
	for i, states in ui.top_left {
		x := ui.start_x + i * ui.icon_w
		y := ui.start_y
		self.add_icon(states, x, y)
	}
	// top right row of icons
	for i, states in ui.top_right {
		x := lyra.game_width - ui.start_x - (i + 1) * ui.icon_w
		y := ui.start_y
		self.add_icon(states, x, y)
	}
}

// update hud
pub fn (mut self HUD) update(mut game_state state.State) {
	// change icon state
	update_state := fn (mut icon Icon, mut game_state state.State) {
		// updates button state
		if icon.states.len > 1 {
			icon.state++
			if icon.state > icon.states.len - 1 {
				icon.state = 0
			}
		}
		// execute the function
		icon.states[icon.state].execute(game_state)
	}

	// key pressed
	if self.key_timeout > 0 {
		self.key_timeout--
	}
	if vraylib.is_key_down(vraylib.key_m) {
		if self.key_timeout == 0 {
			update_state(mut self.icons[ui.music_button], mut game_state)
		}
		self.key_timeout = 2
	}

	// icons
	pressed := vraylib.is_mouse_button_pressed(vraylib.mouse_button_left)
	mut hover := false
	mx, my := game_state.mouse.x, game_state.mouse.y
	for mut icon in self.icons {
		if mx > icon.x && mx < icon.x + f32(ui.icon_w) * ui.icon_scale && my > icon.y
			&& my < icon.y + f32(ui.icon_h) * ui.icon_scale {
			hover = true
			if pressed {
				update_state(mut icon, mut game_state)
			}
		}
	}
	if hover {
		vraylib.set_mouse_cursor(vraylib.mouse_cursor_crosshair)
	}
}

fn draw_score(game_state &state.State) {
	text := 'Score: ${game_state.score}'
	font_size := 64
	x := int(f32(lyra.game_width) * .5 - f32(vraylib.measure_text(text.str, font_size)) * .5)
	vraylib.draw_text(text.str, x + int(game_state.cx), 60, font_size, vraylib.pink)
}

// draw hud
pub fn (self &HUD) draw(game_state &state.State) {
	for icon in self.icons {
		img := icon.states[icon.state].texture
		vraylib.draw_texture_ex(img, vraylib.Vector2{icon.x + game_state.cx, icon.y}, 0, ui.icon_scale,
			vraylib.white)
	}

	draw_score(game_state)
}

// unload hud
pub fn (self &HUD) unload() {
	for icon in self.icons {
		for btn in icon.states {
			vraylib.unload_texture(btn.texture)
		}
	}
}
