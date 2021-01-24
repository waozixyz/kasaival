local push = require("lib.push")
local suit = require("lib.suit")
local Bckg = require("lib.Bckg")
local Cursor = require("lib.Cursor")
local Saves = require("lib.Saves")

local gr = love.graphics

local function draw(self)
    return Bckg:draw()
end

local function init(self, set_mode)
    Bckg:init()
    Cursor:init()
    self.saves = Saves:getFiles()
    if self.saves and #self.saves < 1 then
        set_mode("lib.Game", "saves/save1")
    end
end
local function keypressd(self, key, set_mode)
    if key == "escape" then
        set_mode("lib.Menu")
    elseif key == "1" then
        set_mode("lib.Game", (Saves.saveName .. "1"))
    elseif key == "2" then
        set_mode("lib.Game", (Saves.saveName .. "2"))
    elseif key == "3" then
        set_mode("lib.Game", (Saves.saveName .. "3"))
    elseif key == "4" then
        set_mode("lib.Game", (Saves.saveName .. "4"))
    elseif key == "return" then
        set_mode("lib.Game", (Saves.saveName .. "1"))
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
local function update(self, dt, set_mode)
    if self.saves then
        for id, sav in pairs(self.saves) do
            local x, y, w, h, scale = getShape(id, sav)
            
            -- if there is an image file make ImageButton otherwise make Button
            if sav.img then
                suit.ImageButton(sav.img, {id = id, scale = scale}, x, y)
            else
                suit.Button(sav.file, {id = id}, x, y, w, h)
            end
            -- if button hit, set_mode
            if suit.isHit(id) then
                if sav.file then
                    set_mode("lib.Game", ("saves/" .. sav.file))
                else
                    set_mode("lib.Game")
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
            set_mode("lib.Game")
        end
        Cursor:update()
    end
end
return {draw = draw, init = init, keypressed = keypressd, update = update}
