module screens

import irishgreencitrus.raylibv as rl
import ui
import state

const start_x = 200
const start_y = 500
const stages = ['shrubland', 'grassland']
const stages_id = [0, 1]
const path = 'resources/stages/'
const ext = '.jpg'

pub struct Carousel {
mut:
    background rl.Texture2D
    stages     []ui.ImageButton
}

pub fn (mut self Carousel) load(mut game_state state.State) {
    game_state.cx = 0
    self.background = rl.load_texture(('resources/menu.jpg').str)

    mut w := 0
    mut off_x := 100
    for i, stage in screens.stages {
        img := rl.load_texture((screens.path + stage + screens.ext).str)
        x := screens.start_x + w + off_x * i
        y := screens.start_y
        self.stages << ui.ImageButton{img, x, y, 1}
        w = img.width
    }
}

fn get_key_action(i int, mut game_state state.State) {
    match i {
        0 {
            game_state.set_screen(&Game{})
        }
        1 {
            game_state.set_screen(&Game{})
        }
        else {}
    }
}

pub fn (mut self Carousel) update(mut game_state state.State) {
    mut key := -1
    key_pressed := rl.get_key_pressed()
    mouse_pressed := rl.is_mouse_button_pressed(rl.mouse_button_left)
    for i, stage in self.stages {
        if stage.mouse_on_button(game_state) {
            if mouse_pressed {
                key = i
            }
        }
    }
    if key_pressed >= 49 && key_pressed < 58 {
        key = key_pressed - 49
    } else if key_pressed >= 321 && key_pressed < 330 {
        key = key_pressed - 321
    }
    get_key_action(key, mut game_state)
}

pub fn (self &Carousel) draw(game_state &state.State) {
    rl.draw_texture_ex(self.background, rl.Vector2{0, 0}, 0, 1, rl.white)
    rl.draw_text(('KASAIVAL').str, 480, 160, 200, rl.maroon)
    for stage in self.stages {
        stage.draw(game_state)
    }
}

pub fn (self &Carousel) unload() {
    rl.unload_texture(self.background)
    for stage in self.stages {
        stage.unload()
    }
}