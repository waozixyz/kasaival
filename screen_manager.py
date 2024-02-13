class ScreenManager:
    def __init__(self):
        self.active_screen = None

    def set_active_screen(self, screen):
        self.active_screen = screen

    def handle_events(self, events):
        if self.active_screen:
            return self.active_screen.handle_events(events)
        return True

    def update(self, elapsed_time):
        if self.active_screen:
            self.active_screen.update(elapsed_time)

    def render(self, surface):
        if self.active_screen:
            self.active_screen.render(surface)
            