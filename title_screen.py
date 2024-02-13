# title_screen.py
import pygame
import sys
from screen_base import BaseScreen
from config import BLACK, VIRTUAL_WIDTH, VIRTUAL_HEIGHT

class TitleScreen(BaseScreen):
    def __init__(self, screen_scaler, on_start):
        super().__init__(screen_scaler)
        self.on_start = on_start

    def handle_events(self, events):
        for event in events:
            if event.type == pygame.QUIT:
                sys.exit()
            elif event.type == pygame.KEYDOWN:
                self.on_start()  # Switch to GameScreen on any key press

    def render(self, surface):
        surface.fill(BLACK)
        font = pygame.font.Font(None, 74)
        text = font.render("Title Screen", True, (255, 255, 255))
        text_rect = text.get_rect(center=(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2))
        surface.blit(text, text_rect)