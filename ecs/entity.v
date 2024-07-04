module ecs

import plants
import mobs
import lyra
import rand
import state

interface Entity {
mut:
    y f32
    dead bool
    points int
    load(int, int)
    update(mut game_state &state.State)
    unload()
    draw(game_state &state.State)
    collided(string, f32)
    get_hitbox() []f32
}

pub enum EntityName {
    // mobs
    dog
    frog
    fox
    // plants
    saguaro
    kali
    oak
}

pub fn get_spawn_pos(start_x int, end_x int) (int, int) {
    x := rand.int_in_range(start_x, end_x) or { 0 }
    y := rand.int_in_range(lyra.start_y, lyra.game_height) or { 0 }
    return x, y
}

pub fn check_collision(a []f32, b []f32) bool {
    if a[0] < b[1] && a[1] > b[0] && a[2] < b[3] && a[3] > b[2] {
        return true
    } else {
        return false
    }
}

pub fn new_entity(name EntityName) Entity {
    match name {
        // mobs
        .dog {
            return &mobs.Dog{}
        }
        .frog {
            return &mobs.Frog{}
        }
        .fox {
            return &mobs.Fox{}
        }
        // plants
        .saguaro {
            return Entity(plants.saguaro())
        }
        .kali {
            return Entity(plants.kali())
        }
        .oak {
            return Entity(plants.oak())
        }
    }
}