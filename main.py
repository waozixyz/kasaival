import pygame
import sys
from scaling_utils import ScreenScaler
from screen_manager import ScreenManager
from game_screen import GameScreen
from config import VIRTUAL_WIDTH, VIRTUAL_HEIGHT, FPS

pygame.init()

window = pygame.display.set_mode((VIRTUAL_WIDTH, VIRTUAL_HEIGHT))
virtual_screen = pygame.Surface((VIRTUAL_WIDTH, VIRTUAL_HEIGHT))
clock = pygame.time.Clock()

infoObject = pygame.display.Info()
SCREEN_WIDTH, SCREEN_HEIGHT = infoObject.current_w, infoObject.current_h

scaler = ScreenScaler(SCREEN_WIDTH, SCREEN_HEIGHT, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
manager = ScreenManager()

game_screen = GameScreen(scaler)

manager.set_active_screen(game_screen)

running = True
while running:
    events = pygame.event.get()
    for event in events:
        if event.type == pygame.QUIT or (event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE):
            sys.exit()
        elif event.type == pygame.KEYDOWN and event.key == pygame.K_f:
            pygame.display.toggle_fullscreen()
    running = manager.handle_events(events)
    manager.update(clock.get_time())
    manager.render(virtual_screen)

    scaled_screen = scaler.scale_surface(virtual_screen)
    
    manager.draw_extra_space(window, scaler)

    window.blit(scaled_screen, (scaler.offset_x, scaler.offset_y))
    
    pygame.display.flip()
    clock.tick(FPS)
pygame.quit()
sys.exit()
