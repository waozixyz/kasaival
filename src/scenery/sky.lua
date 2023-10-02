local gfx = love.graphics
local ma = love.math

local function init(self, sav)
    -- const values
    self.bckg = gfx.newImage("/assets/sky/bckg-2.jpg")
    self.nebula = gfx.newImage("/assets/sky/nebula.png")
    local h = self.bckg:getHeight()
    
    -- default values
	local tmpl = {
        y = ma.random(h * -0.5, 0)
    }
    
    -- replace with sav data
    for k,v in pairs(tmpl) do
        self[k] = sav[k] or v
    end

    return self
end

local function draw(self)
    gfx.setColor(1, 1, 1)
    gfx.draw(self.bckg, 0, self.y)
    gfx.draw(self.nebula, 0, 0)
end

local function update(self, dt)

end
return {draw = draw, init = init, update = update}
