module mobs

import irishgreencitrus.raylibv as rl
import state
import utils

pub struct Fox {
pub mut:
    y f32
mut:
    x       f32
    texture rl.Texture2D
    anime   utils.Animation
    dead    bool
    points  int = 30
}

pub fn (mut self Fox) load(x int, y int) {
    self.x, self.y = x, y
    // self.anime.load('Fox', 20, 12, 153, 139, 0)
}

pub fn (mut self Fox) update(mut game_state &state.State) {
    self.anime.update(self.x, self.y)
}

pub fn (self &Fox) draw(game_state &state.State) {
    self.anime.draw()
}

pub fn (self &Fox) unload() {
    self.anime.unload()
}

pub fn (mut self Fox) collided(element string, dp f32) {
    if element == 'fire' {
        // Add any specific behavior for fire collision
    }
}

pub fn (self &Fox) get_hitbox() []f32 {
    return [self.x, self.x, self.y, self.y]
}