module mobs

import irishgreencitrus.raylibv as rl
import utils
import rand
import state
import lyra

pub struct Dog {
pub mut:
    y f32
mut:
    counter     int
    speed       int = 2
    speed_y     f32 = 1.5
    x           f32
    texture     rl.Texture2D
    anime       utils.Animation
    walk_time   f32
    pee_time    f32
    burn_time   f32
    burning     bool
    dead        bool
    w           int = 100
    h           int = 64
    points      int = 30
    direction_y f32
}

pub fn (mut self Dog) load(x int, y int) {
    self.x, self.y = x, y
    states := {
        'walk': 3
        'pee':  3
        'burn': 6
    }
    self.anime.load('dog', states, 6, self.w, self.h, 7)
    self.walk_time = 5
    self.pee_time = 3
    self.burn_time = .15
    self.counter = rand.int_in_range(0, int(self.walk_time * 60)) or { 0 }
    self.direction_y = rand.f32_in_range(-1, 1) or { 0 }
    self.anime.direction = 1 - rand.intn(2) or { 0 } * 2
}

pub fn (mut self Dog) update(mut game_state &state.State) {
    // aliases
    wt := self.walk_time * 60
    pt := self.pee_time * 60
    bt := self.burn_time * 60

    // update counter
    self.counter++
    if self.burning {
        if self.counter < wt + pt {
            self.counter = int(wt + pt)
        } else if self.counter > wt + pt + bt {
            self.dead = true
        }
    } else {
        if self.counter > wt + pt {
            self.counter = 0
        }
    }

    // set anime state
    if self.counter < wt {
        if self.x > game_state.start_x && self.anime.direction > 0 {
            self.x -= self.speed
        } else if self.x < game_state.start_x + game_state.gw && self.anime.direction < 0 {
            self.x += self.speed
        } else {
            self.anime.direction *= -1
        }

        change_y := self.speed_y * self.direction_y
        if self.y > lyra.start_y - change_y && self.y < lyra.game_height - change_y {
            self.y += change_y
        }
        self.anime.state = 'walk'
    } else if self.counter < wt + pt {
        self.anime.state = 'pee'
        self.direction_y = rand.f32_in_range(-1, 1) or { 0 }
    } else if self.counter < wt + pt + bt {
        self.anime.state = 'burn'
    }

    self.anime.update(self.x, self.y)
}

pub fn (self &Dog) draw(game_state &state.State) {
    self.anime.draw()
}

pub fn (self &Dog) unload() {
    self.anime.unload()
}

pub fn (mut self Dog) collided(element string, dp f32) {
    if element == 'fire' {
        self.burning = true
    }
}

pub fn (self &Dog) get_hitbox() []f32 {
    return [self.x, self.x + f32(self.w), self.y - f32(self.h) * .2, self.y]
}