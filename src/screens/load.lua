local push = require("push")
local suit = require("suit")
local Cursor = require("ui.Cursor")
local Saves = require("sys.Saves")

local gfx = love.graphics


local function init(self, set_screen)
    Cursor:init()
    self.saves = Saves:getFiles()
    if self.saves and #self.saves < 1 then
        set_screen("Game", "saves/ save1")
    end
end
local function keypressed(self, key, set_screen)
    if key == "escape" then
        set_screen("Menu")
    elseif key == "1" or key == "2" or key == "3" or key == "4" then
        set_screen("Game", (Saves.saveName .. key))
    elseif key == "return" then
        set_screen("Game", (Saves.saveName .. "1"))
    end
end

local function getShape(id, sav)
    local W, H = push:getDimensions()
    local w, h = 400, 200
    if sav and sav.img then w, h = sav.img:getDimensions() end
    local scale = (W / w) * 0.2
    local y = H * 0.5 - h * scale * 0.5
    local x = (id - 1) * (w + W * 0.1) * scale + W * 0.05
    return x, y, w * scale, h * scale, scale
end

local function update(self, dt, set_screen)
    if self.saves then
        for id, sav in pairs(self.saves) do
            local x, y, w, h, scale = getShape(id, sav)
            
            -- if there is an image file make ImageButton otherwise make Button
            if sav.img then
                suit.ImageButton(sav.img, {id = id, scale = scale}, x, y)
            else
                suit.Button(sav.file, {id = id}, x, y, w, h)
            end
            -- if button hit, set_screen
            if suit.isHit(id) then
                if sav.file then
                    set_screen("Game", ("saves/" .. sav.file))
                else
                    set_screen("Game")
                end
            end
            suit.Button("delete", {id = id .. "del"}, x + w * .25, y + h + 50, w * .5, 50)
            if suit.isHit(id .. "del") then
                Saves:remove(id)
                table.remove(self.saves, id)
            end
        end
        local id = 1
        while self.saves[id] do
            id = id + 1
        end
        local x, y, w, h = getShape(id, self.saves[#self.saves])

        suit.Button("New Game", {id = id}, x, y, w, h)
        if suit.isHit(id) then
            set_screen("Game")
        end
        Cursor:update()
    end
end

return {draw = draw, init = init, keypressed = keypressed, update = update}