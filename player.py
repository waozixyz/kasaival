import pygame
import random

class Particle:
    def __init__(self, x, y):
        self.start_y = y
        self.x = x
        self.y = y
        self.vel_x = random.uniform(-0.5, 0.5) 
        self.vel_y = random.uniform(-2, -1) 
        self.lifespan = random.randint(20, 50) 
        self.color = (255, random.randint(100, 160), 0)  

    def update(self):
        self.x += self.vel_x
        self.y += self.vel_y
        self.lifespan -= 1
        
        self.color = (self.color[0], max(self.color[1] - 2, 0), 0)

    def draw(self, screen):
        if self.lifespan > 0:
            pygame.draw.circle(screen, self.color, (int(self.x), int(self.y)), 3)
# Improved Player class with simplified move mechanics
class Player:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.radius = 15
        self.color = (255, 0, 0)
        self.speed = 5
        self.target_x = x
        self.target_y = y
        self.is_moving = False
        self.particles = []

    def emit_particles(self):
        for _ in range(random.randint(2, 5)):
            self.particles.append(Particle(self.x, self.y))

    def update_particles(self):
        self.emit_particles()
        for particle in self.particles:
            particle.update()
            if particle.lifespan <= 0:
                self.particles.remove(particle)

    def start_moving(self):
        self.is_moving = True

    def stop_moving(self):
        self.is_moving = False

    def set_target(self, x, y):
        self.target_x = x
        self.target_y = y

    def move_towards_target(self):
        if self.is_moving:
            dx = self.target_x - self.x
            dy = self.target_y - self.y
            distance = (dx**2 + dy**2)**0.5
            if distance > 0: 
                normalized_dx = dx / distance
                normalized_dy = dy / distance
                self.x += normalized_dx * self.speed
                self.y += normalized_dy * self.speed

            if distance < self.speed:
                self.x = self.target_x
                self.y = self.target_y
                self.stop_moving()
                
                