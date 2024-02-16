import pygame
import noise 

class Ground:
    def __init__(self, screen_width, screen_height, tile_size=32, scale=0.1, octaves=1, persistence=0.5, lacunarity=2.0):
        self.screen_width = screen_width
        self.screen_height = screen_height
        self.tile_size = tile_size
        self.scale = scale
        self.octaves = octaves
        self.persistence = persistence
        self.lacunarity = lacunarity
        self.terrain_colors = {
            'grass': (50, 205, 50),
            'jungle': (34, 139, 34),
            'desert': (210, 180, 140),
            'beach': (238, 214, 175),
            'lake': (30, 144, 255),
            'ocean': (0, 105, 148)
        }
        self.tiles = self.generate_tiles_using_perlin_noise()

    def generate_tiles_using_perlin_noise(self):
        cols = self.screen_width // self.tile_size
        rows = self.screen_height // self.tile_size
        tiles = []

        for y in range(rows):
            row = []
            for x in range(cols):
                nx = x / cols - 0.5
                ny = y / rows - 0.5
                # Generate Perlin noise value for each tile
                noise_val = noise.pnoise2(nx * self.scale, 
                                          ny * self.scale, 
                                          octaves=self.octaves, 
                                          persistence=self.persistence, 
                                          lacunarity=self.lacunarity, 
                                          repeatx=1024, 
                                          repeaty=1024, 
                                          base=0)
                terrain_type = self.determine_terrain_type(noise_val)
                row.append(terrain_type)
            tiles.append(row)
        return tiles

    def determine_terrain_type(self, noise_val):
        if noise_val < -0.05:
            return 'ocean'
        elif noise_val < 0.0:
            return 'lake'
        elif noise_val < 0.2:
            return 'beach'
        elif noise_val < 0.4:
            return 'grass'
        elif noise_val < 0.6:
            return 'jungle'
        else:
            return 'desert'

    def draw(self, screen):
        for y, row in enumerate(self.tiles):
            for x, terrain_type in enumerate(row):
                color = self.terrain_colors[terrain_type]
                pygame.draw.rect(screen, color, (x * self.tile_size, y * self.tile_size, self.tile_size, self.tile_size))