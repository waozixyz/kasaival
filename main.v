module main

import irishgreencitrus.raylibv as rl
import screens
import state
import lyra

fn max(a f32, b f32) f32 {
    return if a > b { a } else { b }
}

fn min(a f32, b f32) f32 {
    return if a < b { a } else { b }
}

// Clamp Vector2 value with min and max and return a new vector2
fn clamp_value(value rl.Vector2, min rl.Vector2, max rl.Vector2) rl.Vector2 {
    mut result := value
    result.x = if result.x > max.x { max.x } else { result.x }
    result.x = if result.x < min.x { min.x } else { result.x }
    result.y = if result.y > max.y { max.y } else { result.y }
    result.y = if result.y < min.y { min.y } else { result.y }
    return result
}

// Constant Variables Definition
const (
    screen_width  = 800
    screen_height = 450
    window_title  = 'Kasaival'
)

fn main() {
    rl.set_config_flags(rl.flag_window_resizable | rl.flag_vsync_hint)
    rl.init_window(screen_width, screen_height, window_title.str)

    target := rl.load_render_texture(lyra.game_width, lyra.game_height)

    rl.init_audio_device()

    mut game_state := &state.State{
        screen: &screens.Game{}
    }
    mut camera := rl.Camera2D{}
    game_state.screen.load(mut game_state)

    mut key_timeout := 0

    rl.set_target_fps(60)

    for {
        if rl.window_should_close() {
            break
        }
        {
            scale := min(f32(rl.get_screen_width()) / lyra.game_width, f32(rl.get_screen_height()) / lyra.game_height)

            if key_timeout > 0 {
                key_timeout--
            }
            if rl.is_key_down(rl.key_f) {
                if key_timeout == 0 {
                    rl.toggle_fullscreen()
                }
                key_timeout = 2
            }
            game_state.screen.update(mut game_state)

            camera.target = rl.Vector2{game_state.cx, 0}
            camera.zoom = 1

            mouse := rl.get_mouse_position()
            mut virtual_mouse := rl.Vector2{}
            virtual_mouse.x = (mouse.x - (rl.get_screen_width() - (lyra.game_width * scale)) * .5) / scale
            virtual_mouse.y = (mouse.y - (rl.get_screen_height() - (lyra.game_height * scale)) * .5) / scale
            game_state.mouse = clamp_value(virtual_mouse, rl.Vector2{}, rl.Vector2{lyra.game_width, lyra.game_height})

            rl.begin_drawing()
            {
                rl.clear_background(rl.black)
                rl.begin_texture_mode(target)
                {
                    rl.begin_mode_2d(camera)
                    {
                        rl.clear_background(rl.black)
                        game_state.screen.draw(game_state)
                    }
                    rl.end_mode_2d()
                }
                rl.end_texture_mode()
                rl.draw_texture_pro(rl.Texture2D(target.texture),  rl.Rectangle{0, 0, f32(target.texture.width), f32(-target.texture.height)},
                    rl.Rectangle{(rl.get_screen_width() - lyra.game_width * scale) * .5, (rl.get_screen_height() - (lyra.game_height * scale)) * 0.5, f32(lyra.game_width) * scale, f32(lyra.game_height) * scale},
                    rl.Vector2{}, 0.0, rl.white)
            }
            rl.end_drawing()

            rl.set_mouse_cursor(rl.mouse_cursor_default)
        }
    }

    rl.unload_render_texture(target)
    game_state.screen.unload()

    rl.close_audio_device()
    rl.close_window()
}