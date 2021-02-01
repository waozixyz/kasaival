local suit = require "lib.suit"
local push = require "lib.push"
local lume = require "lib.lume"
local lyra = require "lib.lyra"

local Cursor = require "lib.ui.Cursor"
local Font = require "lib.ui.Font"
local Overlay = require "lib.ui.Overlay"
local Music = require "lib.sys.Music"
local Text = require "lib.ui.Text"

local gr = love.graphics

local function init(self)
    local W = push:getWidth()
    Cursor:init()
    -- load text
    self.gameover = Overlay.getText("GameOver", "touch anywhere or press any key to try again", {0, 0, 0, 0.5})
    self.gamepaused = Overlay.getText("Game Paused", "touch anywhere or press any key to unpause", {1, 1, 1, 0.5})
    self.gamesaving = Overlay.getText("Game Saving", "please wait patiently...", {0, 0.2, 0, 0.5})
    -- load quest text
    self.questHeading = Text:init("Quests to complete", {size = 64, y = 20, x = W - 20, align = "right"})
    local i = 1
    for _, v in pairs(lyra:getCurrentQuests()) do
        local size = 48
        v.text = Text:init(v.head .. " " .. v.amount .. " " .. v.tail, {size = size, y = 40 + (size + 8) * i, x = W - 20, align = "right"})
        i = i + 1
    end
    
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


local function draw(self, game)
    local W, H = push:getDimensions()
    local hp = game.player.kelvin

    gr.setColor(.2, 0, 0, 1 - (hp / 100))
    gr.rectangle("fill", 0, 0, W, H)

    -- overlays for special states
    if hp <= 0 then
        Overlay.draw(self.gameover)
    elseif game.paused == true and (not game.exit or game.exit == 0) then
        Overlay.draw(self.gamepaused)
    elseif game.exit == 1 or game.exit == 2 then
        Overlay.draw(self.gamesaving)
    end
    -- current quests
    if lume.count(lyra:getCurrentQuests()) > 0 then
        self.questHeading:draw()
    end
    for _, v in pairs(lyra:getCurrentQuests()) do
        v.text:draw()
    end
    
    -- current music playing
    if Music.songTitle then
        gr.setColor({1, 1, 1})
        local title = gr.newText(Font, "\240\159\142\182 " .. Music.author .. " - " .. Music.title .. " \240\159\142\182")
        gr.draw(title, W - 20, H - 40)
    end
end
local function tk( game)
    if game.paused then
        game.paused = toggle(game.paused)
        return true
    end
    if game.player.kelvin <= 0 then
        game.restart = true
        return true
    end
end
local function touch(self, game, x, y)
    local w, h = self.pause.img:getDimensions()
    if x > w + self.pause.x or y > h + self.pause.y then
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

local function update(self, game)
    local exit_button = suit.ImageButton(self.exit, 20, 20)
    if exit_button.hit == true and game.exit and game.exit < 1 then
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
    if Music:isMuted() then
        music_image = self.nomusic
    end
    local music_button = suit.ImageButton(music_image, self.pause.x + 120, 20)
    if music_button.hit == true then
        Music:toggle()
    end
    Cursor:update()

    -- update quest Text
 
    for k, v in pairs(lyra:getCurrentQuests()) do
        local amount = v.amount
        if k == "kill" then
            amount = amount - game.kill_count[v.type]
        end
        v.text:update(v.head .. " " .. math.floor(amount) .. " " .. v.tail)
    end
end
return {draw = draw, init = init, keypressed = keypressed, touch = touch, update = update}
