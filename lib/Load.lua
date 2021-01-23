local push = require("lib.push")
local suit = require("lib.suit")
local Bckg = require("lib.Bckg")
local Cursor = require("lib.Cursor")
local Saves = require("lib.Saves")

local gr = love.graphics

local function draw(self)
    return Bckg:draw()
end
local function init(self)
    Bckg:init()
    Cursor:init()
    self.saves = Saves:getFiles()
    if (#self.saves < 4) then
        local id = (#self.saves + 1)
        self.saves[id] = {file = ("save" .. id), img = gr.newImage("assets/newGame.jpg")}
    end
end
local function keypressd(self, key, set_mode)
    if (key == "escape") then
        set_mode("lib.Menu")
    end
    if (key == "1") then
        set_mode("lib.Game", (Saves.saveName .. "1"))
    end
    if (key == "2") then
        set_mode("lib.Game", (Saves.saveName .. "2"))
    end
    if (key == "3") then
        set_mode("lib.Game", (Saves.saveName .. "3"))
    end
    if (key == "4") then
        set_mode("lib.Game", (Saves.saveName .. "4"))
    end
    if (key == "return") then
        return set_mode("lib.Game", (Saves.saveName .. "1"))
    end
end
local function update(self, dt, set_mode)
    local W, H = push:getDimensions()
    if self.saves then
        if (#self.saves < 2) then
            set_mode("lib.Game", "saves/save1")
        end
        for id, sav in pairs(self.saves) do
            local w, h = 400, 200
            if sav.img then w, h = sav.img:getDimensions() end
            local scale = ((W / w) * 0.2)
            local y = ((H * 0.5) - (h * scale * 0.5))
            local x = (((id - 1) * (w + (W * 0.1)) * scale) + (W * 0.05))
            
            -- if there is an image file make ImageButton otherwise make Button
            local s
            if sav.img then
                s = suit.ImageButton(sav.img, {scale = scale}, x, y)
            else
                s = suit.Button(sav.file, x, y, w, h)
            end

            -- if button hit, set_mode
            if (s.hit == true) then
                if sav.file then
                    set_mode("lib.Game", ("saves/" .. sav.file))
                else
                    set_mode("lib.Game")
                end
            end
        end
        Cursor:update()
    end
end
return {draw = draw, init = init, keypressed = keypressd, update = update}
