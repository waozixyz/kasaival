import pygame
import random

class Tree:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.growth_stage = 0
        self.growth_progress = 0
        self.time_to_grow = 5000
        self.is_burning = False
        self.burn_progress = 0
        self.burn_rate = 0.001  # Adjust as needed for burn speed
        self.remove = False  # Flag to indicate if the tree should be removed

        self.sizes = [
            {'trunk_width': 5, 'trunk_height': 10, 'foliage_width': 10, 'foliage_height': 10},
            {'trunk_width': 10, 'trunk_height': 30, 'foliage_width': 30, 'foliage_height': 20},
            {'trunk_width': 20, 'trunk_height': 60, 'foliage_width': 60, 'foliage_height': 40},
        ]
        
        self.current_size = self.sizes[0].copy()
        self.update_dimensions()

    def update_dimensions(self):
        # Update dimensions based on current size, growth, and burn progress
        if self.is_burning:
            shrink_factor = max(0, 1 - self.burn_progress)  # Ensure it doesn't go negative
            for key in self.current_size:
                self.current_size[key] *= shrink_factor
        elif self.growth_stage < len(self.sizes) - 1:
            next_size = self.sizes[self.growth_stage + 1]
            for key in self.current_size.keys():
                start = self.sizes[self.growth_stage][key]
                end = next_size[key]
                self.current_size[key] = start + (end - start) * self.growth_progress
        
        self.trunk_width = self.current_size['trunk_width']
        self.trunk_height = self.current_size['trunk_height']
        self.foliage_width = self.current_size['foliage_width']
        self.foliage_height = self.current_size['foliage_height']
        self.width = self.trunk_width
        self.height = self.trunk_height + self.foliage_height
        self.trunk_rect = pygame.Rect(self.x - self.trunk_width // 2, self.y - self.trunk_height, self.trunk_width, self.trunk_height)
        self.foliage_rect = pygame.Rect(self.x - self.foliage_width // 2, self.y - self.trunk_height - self.foliage_height // 2, self.foliage_width, self.foliage_height)

    def update(self, elapsed_time):
        if self.is_burning:
            self.burn_progress += self.burn_rate * elapsed_time
            if self.burn_progress >= 1:
                self.remove = True  # Mark for removal once fully burned
        else:
            if self.growth_stage < len(self.sizes) - 1:
                self.growth_progress += elapsed_time / self.time_to_grow
                if self.growth_progress >= 1.0:
                    self.growth_progress = 0.0
                    self.growth_stage += 1
        self.update_dimensions()

    def draw(self, screen):
        trunk_color = (139, 69, 19) if not self.is_burning else (255, 69, 0)  # Adjust color for burning
        foliage_color = (34, 139, 34) if not self.is_burning else (255, 69, 0)  # Adjust color for burning
        if not self.remove:  # Only draw if not marked for removal
            pygame.draw.rect(screen, trunk_color, self.trunk_rect)
            pygame.draw.ellipse(screen, foliage_color, self.foliage_rect)

    def burn(self):
        self.is_burning = True