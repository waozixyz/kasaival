import pygame
import random

class Sky:
    def __init__(self, width, height, stars):
        self.color = (40, 20, 139) 
        
        self.rect = pygame.Rect(0, 0, width, height)
        self.stars = self.generate_stars(stars, width, height)

    def generate_stars(self, count, width, height):
        return [(random.randint(0, width), random.randint(0, height)) for _ in range(count)]

    def draw(self, screen):
        pygame.draw.rect(screen, self.color, self.rect)
        for star in self.stars:
            pygame.draw.circle(screen, (255, 255, 255), star, random.randint(1, 2)) 