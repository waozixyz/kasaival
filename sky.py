import pygame
import random

class Sky:
    def __init__(self, screen_width, screen_height):
        self.color = (40, 20, 139)  # Dark blue sky color
        self.height = screen_height * 0.2
        self.rect = pygame.Rect(0, 0, screen_width, self.height)
        self.stars = self.generate_stars(100, screen_width, self.height)  # Generate 100 stars

    def generate_stars(self, count, width, height):
        """Generate points representing stars in the sky."""
        return [(random.randint(0, width), random.randint(0, height)) for _ in range(count)]

    def draw(self, screen):
        pygame.draw.rect(screen, self.color, self.rect)
        for star in self.stars:
            pygame.draw.circle(screen, (255, 255, 255), star, random.randint(1, 2))  # Draw stars as small circles