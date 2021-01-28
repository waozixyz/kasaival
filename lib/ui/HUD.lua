local copy = require "lib.copy"
local suit = require "lib.suit"
local push = require "lib.push"

local Cursor = require "lib.ui.Cursor"
local Music = require "lib.Music"
local Text = require "lib.ui.Text"
local gr = love.graphics

-- get text for overlay
local function getText(title, subtitle, color)
    local H = push:getHeight()
    local rtn = {}
    rtn.title = copy(Text:init(title, 64, H * .4))
    rtn.subtitle = copy(Text:init(subtitle, 42, H * .5))
    rtn.color = color
    return rtn
end

local function init(self)
    Cursor:init()
    -- load text
    self.gameover = getText("GameOver", "touch anywhere or press any key to try again", {0, 0, 0, 0.5})
    self.gamepaused = getText("Game Paused", "touch anywhere or press any key to unpause", {1, 1, 1, 0.5})
    self.gamesaving = getText("Game Saving", "please wait patiently...", {0, 0.2, 0, 0.5})

    -- load icons
    self.exit = gr.newImage("assets/icons/exit.png")
    self.resume = gr.newImage("assets/icons/resume.png")
    self.pause = {
        img = gr.newImage("assets/icons/pause.png"),
        x = 140,
        y = 20
    }
    self.music = gr.newImage("assets/icons/music.png")
    self.nomusic = gr.newImage("assets/icons/nomusic.png")
    self.sound = gr.newImage("assets/icons/sound.png")
    self.nosound = gr.newImage("assets/icons/nosound.png")
end


local function toggle(val) if val then return false else return true end end

local function focus(self, game, f)
    if not f then
        if not game.paused then
            self.unpause = true
            game.paused = true
        end
        if not game.muted then
            game.muted = true
            self.unmute = true
        end
    else
        if self.unmute then
            game.muted = false
            self.unmute = false
        end
        if self.unpause then
            game.paused = false
            self.unpause = false
        end
    end
end

local function drawOverlay(item)
    local W, H = push:getDimensions()
    item.title:draw()
    item.subtitle:draw()
    gr.setColor(item.color)
    gr.rectangle("fill", 0, 0, W, H)
end

local function draw(self, game)
    local W, H = push:getDimensions()
    local hp = game.player.hp

    gr.setColor(.2, 0, 0, 1 - (hp / 100))
    gr.rectangle("fill", 0, 0, W, H)

    if hp <= 0 then
        drawOverlay(self.gameover)
    elseif game.paused == true and (not game.exit or game.exit == 0) then
        drawOverlay(self.gamepaused)
    elseif game.exit == 1 or game.exit == 2 then
        drawOverlay(self.gamesaving)
    end

    if Music.songTitle then
        gr.setFont(self.font)
        gr.setColor({1, 1, 1})
        local title = "\240\159\142\182 " .. Music.songAuthor .. " - " .. Music.songTitle .. " \240\159\142\182"
        local w = (self.font):getWidth(title)
        gr.print(title, W - w - 20, H - 40)
    end
end
local function tk( game)
    if game.paused then 
        game.paused = toggle(game.paused)
        return true
    end
    if game.player.hp <= 0 then
        game.restart = true
        return true
    end
end
local function touch(self, game, x, y)
    local w, h =self.pause.img:getDimensions()
    if x > w + self.pause.x or y > h + self.pause.y then
        tk(game)
    end
end

local function keypressed(self, game, key)
    if not tk(game) then
        if key == "kp+" then Music.bgm:setVolume(Music.bgm:getVolume() + .1) end
        if key == "kp-" then Music.bgm:setVolume(Music.bgm:getVolume() - .1) end
        if key == "n" then Music.bgm:stop() end
        if key == "m" then game.muted = toggle(game.muted) end
        if key == "p" or key == "pause" or key == "space" then game.paused = toggle(game.paused) end
        if key == "escape" and (not game.exit or game.exit < 1) then game.exit = 1 end
    end
end

local function update(self, game)
    local W = push:getWidth()
    local exit_button = suit.ImageButton(self.exit, 20, 20)
    if exit_button.hit == true and game.exit < 1 then
        game.exit = 1
    end
    local pause_image = self.pause.img
    if game.paused then
        pause_image = self.resume
    end
    local pause_button = suit.ImageButton(pause_image, self.pause.x, self.pause.y)
    if pause_button.hit == true then
        game.paused = toggle(game.paused)
    end
    local music_image = self.music
    if game.muted then
        music_image = self.nomusic
    end
    local music_button = suit.ImageButton(music_image, W - 128, 20)
    if (music_button.hit == true) then
        game.muted = toggle(game.muted)
    end
    Cursor:update()
end
return {focus = focus, draw = draw, init = init, keypressed = keypressed, touch = touch, update = update}
