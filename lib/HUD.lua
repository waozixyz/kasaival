local suit = require("lib.suit")
local push = require("lib.push")

local Cursor = require("lib.Cursor")
local Music = require("lib.Music")

local gr = love.graphics

local function toggle(val) if val then return false else return true end end

local function drawText(text, font, size, xpad, ypad)
    local W, H = push:getDimensions()

    xpad = xpad or 0
    ypad = ypad or 0
    local w = font:getWidth(text)

    gr.setFont(font)
    gr.print(text, W * 0.5 - w * 0.5 + xpad, H * 0.5 + ypad)
end

local function draw(self, game)
    local W, H = push:getDimensions()
    local hp = game.player.hp

    gr.setColor(.2, 0, 0, 1 - (hp / 100) - .4)
    gr.rectangle("fill", 0, 0, W, H)
    if hp <= 0 then
        gr.setFont(self.bigFont)
        gr.setColor(0, 0, 0, 0.5)
        gr.rectangle("fill", 0, 0, W, H)
        gr.setColor(.6, 0, .3)
        drawText("GameOver", self.bigFont, self.fontSize, 0, 0)
        drawText("touch anywhere or press any key to try again", self.bigFont, self.fontSize, 0, self.fontSize)
    elseif game.paused == true then
        gr.setFont(self.bigFont)
        gr.setColor(1, 1, 1, 0.5)
        gr.rectangle("fill", 0, 0, W, H)
        gr.setColor(.6, 0, .3)
        drawText("Game Paused", self.bigFont, self.fontSize, 0, 0)
        drawText("touch anywhere or press any key to unpause", self.bigFont, self.fontSize, 0, self.fontSize)
    end

    if Music.songTitle then
        gr.setFont(self.font)
        gr.setColor({1, 1, 1})
        local title = "\240\159\142\182 " .. Music.songAuthor .. " - " .. Music.songTitle .. " \240\159\142\182"
        local w = (self.font):getWidth(title)
        gr.print(title, W - w - 20, H - 40)
    end
end
local function init(self)
    Cursor:init()
    self.fontSize = 48
    self.bigFont = gr.newFont("assets/fonts/hintedSymbola.ttf", self.fontSize)
    self.font = gr.newFont("assets/fonts/hintedSymbola.ttf", 32)
    self.exit = gr.newImage("assets/icons/exit.png")
    self.resume = gr.newImage("assets/icons/resume.png")
    self.pause = gr.newImage("assets/icons/pause.png")
    self.music = gr.newImage("assets/icons/music.png")
    self.nomusic = gr.newImage("assets/icons/nomusic.png")
    self.sound = gr.newImage("assets/icons/sound.png")
    self.nosound = gr.newImage("assets/icons/nosound.png")
end
local function tk(self, game)
    if game.paused then game.paused = toggle(game.paused) end
    if game.player.hp <= 0 then game.restart = true end
end
local function touch(self, game, x, y)
    tk(self, game)
end
local function keypressd(self, game, key, set_mode)
    tk(self, game)
    if key == "kp+" then Music.bgm:setVolume(Music.bgm:getVolume() + .1) end
    if key == "kp-" then Music.bgm:setVolume(Music.bgm:getVolume() - .1) end
    if key == "n" then Music.bgm:stop() end
    if key == "m" then game.muted = toggle(game.muted) end
    if key == "p" or key == "pause" or key == "space" then game.paused = toggle(game.paused) end
    if key == "escape" then game.paused = true game.exit = true end
end
local function update(self, game)
    local W, H = push:getDimensions()
    local exit_button = suit.ImageButton(self.exit, 20, 20)
    if exit_button.hit == true then
        game.exit = true
    end
    local pause_image = self.pause
    if game.paused then
        pause_image = self.resume
    end
    local pause_button = suit.ImageButton(pause_image, 100, 20)
    if pause_button.hit == true then
        game.paused = toggle(game.paused)
    end
    local music_image = self.music
    if game.muted then
        music_image = self.nomusic
    end
    local music_button = suit.ImageButton(music_image, (W - 84), 20)
    if (music_button.hit == true) then
        game.muted = toggle(game.muted)
    end
    Cursor:update()
end
return {draw = draw, init = init, keypressed = keypressd, touch = touch, update = update}
