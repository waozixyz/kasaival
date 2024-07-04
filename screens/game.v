module screens

import irishgreencitrus.raylibv as rl
import lyra
import player
import scenery
import stages
import ecs
import ui
import state

enum ToOrder {
    player
    entity
}

struct Z_Order {
mut:
    entity ToOrder
    y      f32
    i      int
}

pub struct Game {
mut:
    stage        stages.Shrubland
    entities     []ecs.Entity
    entity_order []Z_Order
    player       player.Core = player.Core{}
    ground       scenery.Ground
    background   scenery.Background = scenery.Background{}
    sky          scenery.Sky        = scenery.Sky{}
    music        rl.Music
    hud          ui.HUD
    elapsed      f32
}

fn (mut self Game) add_entity(name ecs.EntityName, start_x int, end_x int) {
    mut obj := ecs.new_entity(name)
    x, y := ecs.get_spawn_pos(start_x, end_x)
    obj.load(x, y)
    mut found_blank := false
    for i, entity in self.entities {
        match entity {
            ecs.Blank {
                self.entities[i] = obj
                found_blank = true
                return
            }
            else {}
        }
    }
    if !found_blank {
        self.entities << obj
    }
}

fn (mut self Game) load_stage(mut game_state state.State) {
    self.stage = stages.Shrubland{}
    self.stage.load()
		self.music = rl.load_music_stream(('resources/music/' + self.stage.music).str)
    rl.play_music_stream(self.music)
    game_state.gw = 0

    for scene in self.stage.scenes {
        game_state.gw += scene.width
    }
    game_state.start_x = int(-f32(game_state.gw) * .5 + lyra.game_width * .5)
    for mut obj in self.stage.spawners {
        obj.start_x += game_state.start_x
        obj.end_x += game_state.start_x
    }

    self.ground = scenery.Ground{}
    scenes := self.stage.scenes
    mut x := f32(game_state.start_x)
    for i, scene in scenes {
        if i < scenes.len - 1 {
            dire := if i < f32(scenes.len) * .5 { 1 } else { 0 }
            x = self.ground.add_section(x, scene.width, [scenes[i].color, scenes[i + 1].color],
                dire)
        }
    }

    self.player.load()
    self.sky.load()
}

pub fn (mut self Game) load(mut game_state state.State) {
    self.load_stage(mut game_state)
    self.hud = ui.HUD{}
    self.hud.load()
    game_state.cx = 0
    game_state.mute = false
}

pub fn (mut self Game) update(mut game_state state.State) {
    delta := rl.get_frame_time()
    self.elapsed += delta

    defer {
        if game_state.exit {
            game_state.set_screen(&Title{})
            game_state.exit = false
        }
    }

    if !game_state.mute {
        rl.update_music_stream(self.music)
    }
    if !game_state.pause {
        for mut obj in self.stage.spawners {
            obj.timer += delta
            if obj.timer >= obj.interval {
                self.add_entity(obj.name, obj.start_x, obj.end_x)
                obj.timer = 0
            }
        }
        self.background.update(game_state)
        self.sky.update(game_state)
        self.ground.update()

        self.entity_order = []Z_Order{}
        for i, mut entity in self.entities {
            if !entity.dead {
                entity.update(mut game_state)
                self.entity_order << Z_Order{.entity, entity.y, i}

                if ecs.check_collision(self.player.get_hitbox(), entity.get_hitbox()) {
                    entity.collided(self.player.element, self.player.dp)
                }
            } else {
                game_state.score += entity.points
                self.entities[i] = &ecs.Blank{}
            }
        }

        self.player.update(mut game_state)
        fuel := self.ground.collide(self.player.get_hitbox(), self.player.element, self.player.dp)
        self.player.burn(fuel)
        for i, p in self.player.flame.particles {
            self.entity_order << Z_Order{.player, p.y, i}
        }
        self.entity_order.sort(a.y < b.y)
    }

    self.hud.update(mut game_state)
}

pub fn (mut self Game) draw(game_state &state.State) {
    self.background.draw(game_state)
    self.sky.draw(game_state)
    self.ground.draw(game_state)

    for mut obj in self.entity_order {
        match obj.entity {
            .player { self.player.draw(obj.i) }
            .entity { self.entities[obj.i].draw(game_state) }
        }
    }
    self.hud.draw(game_state)
}

pub fn (mut self Game) unload() {
    rl.unload_music_stream(self.music)
    self.background.unload()
    self.sky.unload()
    self.ground.unload()
    self.player.unload()
    for mut entity in self.entities {
        entity.unload()
    }
    self.hud.unload()
}