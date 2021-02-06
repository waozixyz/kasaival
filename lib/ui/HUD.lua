local suit = require "lib.suit"
local push = require "lib.push"
local lume = require "lib.lume"
local lyra = require "lib.lyra"
local font= require "lib.ui.font"

local Cursor = require "lib.ui.Cursor"
local Fuel = require "lib.player.Fuel"
local Overlay = require "lib.ui.Overlay"
local Music = require "lib.sys.Music"
local Tank = require "lib.ui.Tank"
local Text = require "lib.ui.Text"

local gr = love.graphics


local function setCurrentQuests()
    local W = push:getWidth()

    local i = 1
    for _, v in pairs(lyra:getCurrentQuests()) do
        local size = 48
        v.text = Text:init(v.head .. " " .. v.amount .. " " .. v.tail, {size = size, y = 40 + (size + 8) * i, x = W - 20, align = "right"})
        i = i + 1
    end
end

local btns = {
    exit = {
        img = "exit.png",
        fnc = function() love.event.quit() end
    },
    pause = {
        isOn = function(game) if game.paused then return true end end,
        on = "resume.png",
        off = "pause.png",
        fnc = function(game, toggle) game.paused = toggle(game.paused) end
    },
    music = {
        isOn = function() if Music:isMuted() then return false else return true end end,
        on = "music.png",
        off = "nomusic.png",
        fnc = function() Music:toggle() end
    },
}

local function init(self)
    local W = push:getWidth()
    Cursor:init()
    -- load text
    self.gameover = Overlay:init("GameOver", "touch anywhere or press any key to try again", {0, 0, 0, 0.5})
    self.gamepaused = Overlay:init("Game Paused", "touch anywhere or press any key to unpause", {1, 1, 1, 0.5})
    self.gamesaving = Overlay:init("Game Saving", "please wait patiently...", {0, 0.2, 0, 0.5})
    -- load quest text
    self.questHeading = Text:init("Quests to complete", {size = 64, y = 20, x = W - 20, align = "right"})
    setCurrentQuests()
    -- load kelvin meter
    self.tank = Tank:init()

    
    -- load images of button icons
    local path = "assets/icons/"
    for _, v in pairs(btns) do
        for k, img in pairs(v) do
            if (k == "on" or k == "off" or k == "img") and type(img) == "string" then
                v[k] = gr.newImage(path .. img)
            end
        end
    end
end


local function toggle(val) if val then return false else return true end end


local function draw(self, game)
    local W, H = push:getDimensions()
    gr.setColor(.2, 0, 0, 1 - Fuel.amount / Fuel.max * 2)
    gr.rectangle("fill", 0, 0, W, H)

    -- overlays for special states
    if Fuel.amount <= 0 then
        self.gameover:draw()
    elseif game.paused == true and (not game.exit or game.exit == 0) then
        self.gamepaused:draw()
    elseif game.exit == 1 or game.exit == 2 then
        self.gamesaving:draw()
    end
    -- current quests
    if lume.count(lyra:getCurrentQuests()) > 0 then
        self.questHeading:draw()
    end
    for _, v in pairs(lyra:getCurrentQuests()) do
        if not v.text then
            setCurrentQuests()
        end
        v.text:draw()
    end

    -- draw kelvin meter
    self.tank:draw()
    
    -- current music playing
    if Music.songTitle then
        gr.setColor({1, 1, 1})
        local title = gr.newText(font, "\240\159\142\182 " .. Music.author .. " - " .. Music.title .. " \240\159\142\182")
        gr.draw(title, W - 20, H - 40)
    end
end
local function tk( game)
    if game.paused then
        game.paused = toggle(game.paused)
        return true
    end
    if Fuel.amount <= 0 then
        game.restart = true
        return true
    end
end
local function touch(self, game, x, y)
    local w, h = btns.pause.img:getDimensions()
    if x > w + btns.pause.x or y > h + btns.pause.y then
        tk(game)
    end
end

local function keypressed(self, game, key)
    if not tk(game) then
        if key == "kp+" then Music:up() end
        if key == "kp-" then Music:down() end
        if key == "n" then Music:next() end
        if key == "m" then Music:toggle() end
        if key == "p" or key == "pause" or key == "space" then game.paused = toggle(game.paused) end
        if key == "escape" and (not game.exit or game.exit < 1) then game.exit = 1 end
    end
end

local function updateButtons(self, game)
    local x, y = 64, 20
    local padd = 120
    for _, v in pairs(btns) do
        v.x, v.y = x, y
        if v.isOn and v.isOn(game) then
            v.img = v.on
        elseif v.off then
            v.img = v.off
        end
        local button = suit.ImageButton(v.img, v.x, v.y)
        if button.hit == true then
            v.fnc(game, toggle)
        end
        x = x + padd
    end

end

local function update(self, game)
    updateButtons(self, game)
    Cursor:update()
    -- update kelvin meter
    self.tank:update()
    -- update quest Text
 
    for k, v in pairs(lyra:getCurrentQuests()) do
        local amount = v.amount
        if k == "kill" then
            amount = amount - lyra:getKillCount(v.type)
        end
        if v.text == nil then
            setCurrentQuests()
        end
        v.text:update(v.head .. " " .. math.floor(amount) .. " " .. v.tail)
    end
end
return {draw = draw, init = init, keypressed = keypressed, touch = touch, update = update}
