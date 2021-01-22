local gr = love.graphics
local ma = love.math

local function init(self, sav)
    self.bckg = gr.newImage("/assets/sky/bckg-2.jpg")
    local h = self.bckg:getHeight()
    self.y = (sav.y or ma.random((h * -0.5), 0))
    self.nebula = gr.newImage("/assets/sky/nebula.png")
end

local function draw(self)
    gr.setColor(1, 1, 1)
    gr.draw(self.bckg, 0, self.y)
    gr.draw(self.nebula, 0, 0)
end

local function update(self, dt)

end
return {draw = draw, init = init, update = update}
