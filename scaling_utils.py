import pygame

class ScreenScaler:
    def __init__(self, screen_width, screen_height, virtual_width, virtual_height):
        self.screen_width = screen_width
        self.screen_height = screen_height
        self.virtual_width = virtual_width
        self.virtual_height = virtual_height
        self.update_scale_factors(screen_width, screen_height)

    def update_scale_factors(self, new_screen_width, new_screen_height):
        self.screen_width = new_screen_width
        self.screen_height = new_screen_height
        self.scale_factor = self.calculate_scale_factors()
        self.offset_x, self.offset_y = self.calculate_offsets()

    def calculate_scale_factors(self):
        # Calculate scale factors based on current mode (windowed or fullscreen)
        scale_width = self.screen_width / self.virtual_width
        scale_height = self.screen_height / self.virtual_height
        # Apply scaling only if necessary
        return min(scale_width, scale_height) if self.screen_width != self.virtual_width or self.screen_height != self.virtual_height else 1

    def calculate_offsets(self):
        # Calculate offsets only if scaling is applied
        if self.scale_factor > 1:
            offset_x = (self.screen_width - (self.virtual_width * self.scale_factor)) / 2
            offset_y = (self.screen_height - (self.virtual_height * self.scale_factor)) / 2
        else:
            offset_x, offset_y = 0, 0
        return offset_x, offset_y

    def convert_coordinates(self, x, y):
        # Convert screen coordinates to virtual coordinates, considering scaling
        virtual_x = (x - self.offset_x) / self.scale_factor
        virtual_y = (y - self.offset_y) / self.scale_factor
        return int(virtual_x), int(virtual_y)

    def scale_surface(self, virtual_screen):
        # Scale the virtual screen to the actual screen size, if necessary
        if self.scale_factor > 1:
            return pygame.transform.scale(virtual_screen, (int(self.virtual_width * self.scale_factor), int(self.virtual_height * self.scale_factor)))
        else:
            return virtual_screen
