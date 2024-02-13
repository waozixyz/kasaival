 # game_screen.py
import sys
import pygame
import random
from screen_base import BaseScreen
from player import Player
from ground import Ground
from sky import Sky
from tree import Tree

from config import BLACK, VIRTUAL_WIDTH, VIRTUAL_HEIGHT, SPAWN_INTERVAL

class GameScreen(BaseScreen):
    def __init__(self, screen_scaler):
        super().__init__(screen_scaler)
        self.player = Player(VIRTUAL_WIDTH // 2, VIRTUAL_HEIGHT // 2)
        self.ground = Ground(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        self.sky = Sky(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        self.trees = []
        self.last_spawn_time = pygame.time.get_ticks()

    def handle_events(self, events):
        for event in events:
            if event.type in [pygame.MOUSEBUTTONDOWN, pygame.MOUSEMOTION]:
                if event.type == pygame.MOUSEBUTTONDOWN or self.player.is_moving:
                    converted_x, converted_y = self.scaler.convert_coordinates(*event.pos)
                    self.player.set_target(converted_x, converted_y)
                    if event.type == pygame.MOUSEBUTTONDOWN:
                        self.player.start_moving()
            elif event.type == pygame.MOUSEBUTTONUP:
                self.player.stop_moving()
        return True
    
    def update(self, elapsed_time):
        self.player.move_towards_target()
        self.player.update_particles()

        current_time = pygame.time.get_ticks()

        if current_time - self.last_spawn_time > SPAWN_INTERVAL:
            new_tree = Tree(random.randint(0, VIRTUAL_WIDTH), random.randint(self.ground.rect.top, self.ground.rect.bottom))
            self.trees.append(new_tree)
            self.last_spawn_time = current_time

        for tree in self.trees:
            tree.update(elapsed_time)

    def render(self, surface):
        surface.fill(BLACK)
        self.sky.draw(surface)
        self.ground.draw(surface)

        entities = self.trees + self.player.particles
        for entity in sorted(entities, key=lambda entity: getattr(entity, 'start_y', entity.y)):
            entity.draw(surface)
