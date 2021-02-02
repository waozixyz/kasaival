local gr = love.graphics


local function init(self)
    self.anime = new_anime(gr.newImage("assets/mobs/whildwind.png"), 16, 19, 1)
    return self
end



local function draw(self)
    gr.draw(self.anime.spriteSheet, self.anime.quads[get_sprite_num(self)],200, 200, 0, 2, 2)
end



local function update(self, dt)
    self.anime.currentTime = self.anime.currentTime + dt
    if self.anime.currentTime >= self.anime.duration then
        self.anime.currentTime = 0
    end
end 

return {init = init, draw = draw, update = update}