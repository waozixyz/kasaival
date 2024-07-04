module screens

import irishgreencitrus.raylibv as rl
import state

pub struct Title {
mut:
    background rl.Texture2D
}

pub fn (mut self Title) load(mut game_state state.State) {
    self.background = rl.load_texture(c'resources/menu.jpg')
}

pub fn (self Title) update(mut game_state state.State) {
    if rl.is_mouse_button_pressed(rl.mouse_button_left) || rl.get_key_pressed() > 0 {
        game_state.set_screen(&Carousel{})
    }
}

pub fn (self &Title) draw(game_state &state.State) {
    rl.draw_texture_ex(self.background, rl.Vector2{0, 0}, 0, 1, rl.white)
    rl.draw_text(c'KASAIVAL', 480, 160, 200, rl.maroon)
    rl.draw_text(c'an out of control flame trying to survive', 350, 640, 60, rl.maroon)
    rl.draw_text(c'touch anywhere to start burning', 480, 1000, 60, rl.beige)
}

pub fn (self &Title) unload() {
    rl.unload_texture(self.background)
}