local suit = require "suit"
local push = require "push"
local lume = require "lume"
local statBar = require "ui.statBar"
local lyra = require "lyra"

local Cursor = require "ui.Cursor"
local Overlay = require "ui.Overlay"
local Music = require "sys.Music"
local Text = require "ui.Text"

local gfx = love.graphics

local function toggle(val) if val then return false else return true end end

local function getCurrentQuestsText()
    local W = push:getWidth()

    local i = 1
    for _, v in pairs(lyra:getCurrentQuests()) do
        local size = 12
        v.text = Text:init(v.head .. " " .. v.amount .. " " .. v.tail, {size = size, y = 32 + (size + 4) * i, x = W - 20, align = "right"})
        i = i + 1
    end
end

local btns = {
    exit = {
        img = "exit.png",
        fnc = function() lyra.exit = 1 end
    },
    pause = {
        isOn = function() if lyra.paused then return true end end,
        on = "resume.png",
        off = "pause.png",
        fnc = function() lyra.paused = toggle(lyra.paused) end
    },
    music = {
        isOn = function() if Music:isMuted() then return false else return true end end,
        on = "music.png",
        off = "nomusic.png",
        fnc = function() Music:toggle() end
    },
}

local overlays = {
    {name = "Game Over", message = "Touch anywhere or press any key to try again", color = {0, 0, 0, 0.5}},
    {name = "Game Paused", message = "Touch anywhere or press any key to unpause", color = {1, 1, 1, 0.5}},
    {name = "Game Saving", message = "Please wait patiently...", color = {0, 0.2, 0, 0.5}},
    {name = "Game Restarting", message = "Please wait patiently...", color = {0, 0.2, 0, 0.5}},
    {name = "Quest Failed", message = "Touch anywhere or press any key to try again", color = {0.1, 0, 0.1, 0.7}}
}

local function loadText(self)
    for i, overlay in ipairs(overlays) do
        self[overlay.name:lower():gsub(" ", "")] = Overlay:init(overlay.name, overlay.message, overlay.color)
    end
    
    local W = push:getWidth()
    self.questHeading = Text:init("Current Quests", {size = 32, y = 20, x = W - 20, align = "right"})
end

local function loadImage(path, img)
    if type(img) == "string" then
        return gfx.newImage(path .. img)
    end
    return img
end

local function loadImages(self, btns)
    local path = "assets/icons/"
    for _, v in pairs(btns) do
        for k, img in pairs(v) do
            if k == "on" or k == "off" or k == "img" then
                v[k] = loadImage(path, img)
            end
        end
    end
end

local function init(self)
    Cursor:init()
    loadText(self)
    getCurrentQuestsText()
    loadImages(self, btns)
    return self
end

local function draw(self)
    local W, H = push:getDimensions()
    gfx.setColor(.2, 0, 0, 1 - lyra.player.HP / lyra.player.maxHP * 5)
    gfx.rectangle("fill", 0, 0, W, H)

    -- overlays for special states
    if lyra.restart then
        self.gamerestart:draw()
    elseif lyra.questFailed then
        self.questfail:draw(lyra:getCurrentQuestHint())
    elseif lyra.player.HP <= 0 then
        self.gameover:draw()
    elseif lyra.paused == true and (not lyra.exit or lyra.exit == 0) then
        self.gamepaused:draw()
    elseif lyra.exit == 1 or lyra.exit == 2 then
        self.gamesaving:draw()
    end
 
    -- current quests
    if lume.count(lyra:getCurrentQuests()) > 0 then
        self.questHeading:draw()
    end
    for _, v in pairs(lyra:getCurrentQuests()) do
        if not v.text then
            getCurrentQuestsText()
        end
        v.text:draw()
    end

    -- draw LifeBar
    statBar(70, lyra.player.HP, lyra.player.maxHP, "HP", {0.5, 0, 0.2}, true)
    -- statBar(220,lyra.player.XP, lyra.player.maxXP, "XP", {.2, 0, .5})
end
local function tk()
    if lyra.paused then
        lyra.paused = toggle(lyra.paused)
        return true
    end
    if lyra.player.HP <= 0 or lyra.questFailed then
        lyra.restart = true
        return true
    end
    return false
end
local function touch(x, y)
    if btns.pause.img then
        local w, h = btns.pause.img:getDimensions()
        if x > w + btns.pause.x or y > h + btns.pause.y then
            tk()
        end
    end
end

local function keypressed(key)

    if not tk() and isOnlyKey then
        if key == "kp-" then Music:down() end
        if key == "n" then Music:next() end
        if key == "m" then Music:toggle() end
        if key == "r" then lyra.restart = true end
        if key == "p" or key == "pause" or key == "space" then lyra.paused = toggle(lyra.paused) end
        if key == "escape" and (not lyra.exit or lyra.exit < 1) then lyra.exit = 1 end
    end
end

local function updateButtons()
    local x, y = 20, 20
    local padd = 50
    for _, v in pairs(btns) do
        v.x, v.y = x, y
        if v.isOn and v.isOn() then
            v.img = v.on
        elseif v.off then
            v.img = v.off
        end

        local button = suit.ImageButton(v.img, {scale = 0.8 }, v.x, v.y)
        if button.hit == true then
            v.fnc()
        end
        x = x + padd
    end

end

local function update(self)
    updateButtons()
    Cursor:update()

    -- update quest Text
    if #lyra:getCurrentQuests() > 0 then
        for _, v in ipairs(lyra:getCurrentQuests()) do
            local amount = v.amount
            if v.questType == "kill" then
                amount = amount - lyra:getKillCount(v.itemType)
            end
            if v.text == nil then
                getCurrentQuestsText()
            end
            v.text:update(v.head .. " " .. math.floor(amount) .. " " .. v.tail)
        end
    else
        print("no quest")
    end
end
return {draw = draw, init = init, keypressed = keypressed, touch = touch, update = update}
