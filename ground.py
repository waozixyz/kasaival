import pygame

class Ground:
    def __init__(self, screen_width, screen_height):
        self.color = (50, 205, 50)  # Marsh green color
        y = screen_height * 0.2
        self.rect = pygame.Rect(0, y, screen_width, screen_height * 0.8)

    def draw(self, screen):
        pygame.draw.rect(screen, self.color, self.rect)