local suit = require("lib.suit")
local push = require("lib.push")

local Cursor = require("src.Cursor")
local Music = require("src.Music")

local gr = love.graphics
local mo = love.mouse

local function toggle(val)
    if val then
        return false
    else
        return true
    end
end

local function drawText(text, font, size, xpad, ypad)
    local W, H = push:getDimensions()

    local xpad0 = (xpad or 0)
    local ypad0 = (ypad or 0)
    local w = font:getWidth(text)

    gr.setFont(font)
    return gr.print(text, (((W * 0.5) - (w * 0.5)) + xpad0), ((H * 0.5) + ypad0))
end

local function draw(self, game)
    local W, H = push:getDimensions()
    local hp = game.player.hp
    local alpha = (1 / (hp / 170) - 1)
    if alpha > .4 then alpha = .4 end

    gr.setColor(.2, 0, 0, alpha)
    gr.rectangle("fill", 0, 0, W, H)
    gr.rectangle("fill", 0, 0, W, H)

    if (hp <= 0) then
        gr.setFont(self.bigFont)
        gr.setColor(0, 0, 0, 0.5)
        gr.rectangle("fill", 0, 0, W, H)
        gr.setColor(.6, 0, .3)
        drawText("GameOver", self.bigFont, self.fontSize, 0, 0)
        drawText("touch anywhere or press any key to try again", self.bigFont, self.fontSize, 0, self.fontSize)
    end

    if Music.songTitle then
        gr.setFont(self.font)
        gr.setColor({1, 1, 1})
        local title = ("\240\159\142\182 " .. Music.songAuthor .. " - " .. Music.songTitle .. " \240\159\142\182")
        local w = (self.font):getWidth(title)
        return gr.print(title, (W - w - 20), (H - 40))
    end
end
local function init(self)
    Cursor:init()
    self.fontSize = 48
    self.bigFont = gr.newFont("assets/fonts/hintedSymbola.ttf", self.fontSize)
    self.font = gr.newFont("assets/fonts/hintedSymbola.ttf", 20)
    self.exit = gr.newImage("assets/icons/exit.png")
    self.resume = gr.newImage("assets/icons/resume.png")
    self.pause = gr.newImage("assets/icons/pause.png")
    self.music = gr.newImage("assets/icons/music.png")
    self.nomusic = gr.newImage("assets/icons/nomusic.png")
    self.sound = gr.newImage("assets/icons/sound.png")
    self.nosound = gr.newImage("assets/icons/nosound.png")
end

local function keypressd(self, game, key, set_mode)
    if (key == "kp+") then Music.bgm:setVolume(Music.bgm:getVolume() + .1) end
    if (key == "kp-") then Music.bgm:setVolume(Music.bgm:getVolume() - .1) end
    if (key == "n") then Music.bgm:stop() end
    if (key == "m") then game.muted = toggle(game.muted) end
    if (key == "p" or key == "pause") then game.paused = toggle(game.paused) end
    if (key == "escape") then game.paused = true game.exit = true end
end
local function update(self, game)
    local W, H = push:getDimensions()
    local exit_button = suit.ImageButton(self.exit, 20, 20)
    if (exit_button.hit == true) then
        game.exit = true
    end
    local pause_image = self.pause
    if game.paused then
        pause_image = self.resume
    end
    local pause_button = suit.ImageButton(pause_image, 100, 20)
    if (pause_button.hit == true) then
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
    return Cursor:update()
end
return {draw = draw, init = init, keypressed = keypressd, update = update}
