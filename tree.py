# tree.py
import pygame

class Tree:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.trunk_color = (139, 69, 19)  # Brown
        self.foliage_color = (34, 139, 34)  # Green
        self.trunk_width = 20
        self.trunk_height = 60
        self.foliage_width = 60
        self.foliage_height = 40
        self.trunk_rect = pygame.Rect(self.x - self.trunk_width // 2, self.y - self.trunk_height, self.trunk_width, self.trunk_height)
        self.foliage_rect = pygame.Rect(self.x - self.foliage_width // 2, self.y - self.trunk_height - self.foliage_height // 2, self.foliage_width, self.foliage_height)

    def draw(self, screen):
        pygame.draw.rect(screen, self.trunk_color, self.trunk_rect)
        pygame.draw.ellipse(screen, self.foliage_color, self.foliage_rect)
        import pygame

class Tree:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.growth_stage = 0  # 0=seed, 1=sapling, 2=full-grown
        self.max_growth_stage = 2
        self.growth_time = 0  # Time since last growth
        self.time_to_grow = 1000  # Time needed to grow to the next stage

        # Initial sizes for seed
        self.trunk_width = 5
        self.trunk_height = 10
        self.foliage_width = 10
        self.foliage_height = 10

        self.update_dimensions()

    def grow(self):
        if self.growth_stage < self.max_growth_stage:
            self.growth_stage += 1
            self.update_dimensions()

    def update_dimensions(self):
        # Adjust dimensions based on the growth stage
        if self.growth_stage == 1:  # Sapling
            self.trunk_width = 10
            self.trunk_height = 30
            self.foliage_width = 30
            self.foliage_height = 20
        elif self.growth_stage == 2:  # Full-grown
            self.trunk_width = 20
            self.trunk_height = 60
            self.foliage_width = 60
            self.foliage_height = 40

        # Update rectangles for drawing
        self.trunk_rect = pygame.Rect(self.x - self.trunk_width // 2, self.y - self.trunk_height, self.trunk_width, self.trunk_height)
        self.foliage_rect = pygame.Rect(self.x - self.foliage_width // 2, self.y - self.trunk_height - self.foliage_height // 2, self.foliage_width, self.foliage_height)

    def update(self, elapsed_time):
        # Update growth based on elapsed time
        self.growth_time += elapsed_time
        if self.growth_time >= self.time_to_grow:
            self.grow()
            self.growth_time = 0  # Reset growth time

    def draw(self, screen):
        pygame.draw.rect(screen, (139, 69, 19), self.trunk_rect)  # Trunk
        pygame.draw.ellipse(screen, (34, 139, 34), self.foliage_rect)  # Foliageimport pygame
import random

class Tree:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.growth_stage = 0  # 0=seed, 1=sapling, 2=full-grown
        self.growth_progress = 0  # Progress towards the next growth stage [0.0, 1.0]
        self.time_to_grow = 5000  # Time needed to fully transition to the next stage

        # Size definitions for each growth stage
        self.sizes = [
            {'trunk_width': 5, 'trunk_height': 10, 'foliage_width': 10, 'foliage_height': 10},  # Seed
            {'trunk_width': 10, 'trunk_height': 30, 'foliage_width': 30, 'foliage_height': 20},  # Sapling
            {'trunk_width': 20, 'trunk_height': 60, 'foliage_width': 60, 'foliage_height': 40},  # Full-grown
        ]
        
        self.current_size = self.sizes[0].copy()
        self.update_dimensions()

    def update_dimensions(self):
        # Calculate the current size based on growth_progress
        if self.growth_stage < len(self.sizes) - 1:
            next_size = self.sizes[self.growth_stage + 1]
            for key in self.current_size.keys():
                start = self.sizes[self.growth_stage][key]
                end = next_size[key]
                self.current_size[key] = start + (end - start) * self.growth_progress
        
        self.trunk_width = self.current_size['trunk_width']
        self.trunk_height = self.current_size['trunk_height']
        self.foliage_width = self.current_size['foliage_width']
        self.foliage_height = self.current_size['foliage_height']

        # Update rectangles for drawing
        self.trunk_rect = pygame.Rect(self.x - self.trunk_width // 2, self.y - self.trunk_height, self.trunk_width, self.trunk_height)
        self.foliage_rect = pygame.Rect(self.x - self.foliage_width // 2, self.y - self.trunk_height - self.foliage_height // 2, self.foliage_width, self.foliage_height)

    def update(self, elapsed_time):
        # Increment growth_progress and update size over time
        if self.growth_stage < len(self.sizes) - 1:
            self.growth_progress += elapsed_time / self.time_to_grow
            if self.growth_progress >= 1.0:
                self.growth_progress = 0.0
                self.growth_stage += 1
            self.update_dimensions()

    def draw(self, screen):
        pygame.draw.rect(screen, (139, 69, 19), self.trunk_rect)  # Trunk
        pygame.draw.ellipse(screen, (34, 139, 34), self.foliage_rect)  # Foliage