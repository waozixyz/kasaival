class BaseScreen:
    def __init__(self, screen_scaler):
        self.scaler = screen_scaler

    def handle_events(self, events):
        pass

    def update(self, elapsed_time):
        pass

    def render(self, surface):
        pass