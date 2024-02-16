 # game_screen.py
import pygame
import random
from screen_base import BaseScreen
from player import Player
from ground import Ground
from sky import Sky
from tree import Tree
from utils import distribute_proportionally

from config import BLACK, VIRTUAL_WIDTH, VIRTUAL_HEIGHT, SPAWN_INTERVAL

class GameScreen(BaseScreen):
    TOTAL_STARS = 100
    def __init__(self, scaler):
        super().__init__(scaler)
        self.player = Player(VIRTUAL_WIDTH // 2, VIRTUAL_HEIGHT // 2)
        self.ground = Ground(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        
        # Heights for the distribution
        border_sky_height = scaler.screen_height - scaler.offset_y
        sky_height = VIRTUAL_HEIGHT * 0.1
        
        # Calculate star distribution using the utility function
        weights = [border_sky_height, sky_height]
        border_sky_stars, sky_stars = distribute_proportionally(weights, GameScreen.TOTAL_STARS)
        
        self.border_sky = Sky(scaler.screen_width, border_sky_height, border_sky_stars)
        self.sky = Sky(VIRTUAL_WIDTH, sky_height, stars=sky_stars)

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
            new_tree = Tree(random.randint(0, VIRTUAL_WIDTH), random.randint(VIRTUAL_HEIGHT * 0.1, VIRTUAL_HEIGHT))
            self.trees.append(new_tree)
            self.last_spawn_time = current_time

        for tree in list(self.trees):
            tree.update(elapsed_time)
            self.trees = [tree for tree in self.trees if not tree.remove]
            
        self.handle_particle_collisions(self.trees)

    def render(self, surface):
        surface.fill(BLACK)
        self.sky.draw(surface)
        self.ground.draw(surface)

        entities = self.trees + self.player.particles
        for entity in sorted(entities, key=lambda entity: getattr(entity, 'start_y', entity.y)):
            entity.draw(surface)
            
    def handle_particle_collisions(self, collidable_entities):
        for particle in list(self.player.particles):  
            circle_center = pygame.math.Vector2(particle.x, particle.y)
            circle_radius = self.player.radius
    
            for entity in collidable_entities:
                entity_rect = pygame.Rect(entity.x, entity.y, entity.width, entity.height)
    
                closest_point = pygame.math.Vector2(max(entity_rect.left, min(circle_center.x, entity_rect.right)),
                                                     max(entity_rect.top, min(circle_center.y, entity_rect.bottom)))
    
                distance = circle_center.distance_to(closest_point)
                if distance <= circle_radius:
                    self.player.particles.remove(particle)
                    entity.burn()
                    break  
    def draw_extra_space(self, window, scaler):
        border_color = (155, 25, 55)
        window.fill(border_color, (0, 0, scaler.screen_width, scaler.offset_y))  
        self.border_sky.draw(window)
     