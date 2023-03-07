local au = love.audio
local ma = love.math

local function toggle(self)
    if self.bgm and self.bgm:isPlaying() then
        self:mute()
    else
        self:play()
    end
end

local function isMuted(self)
    if self.bgm and self.bgm:isPlaying() then
        return false
    else
        return true
    end
end

local function mute(self)
    if self.bgm then
        self.bgm:pause()
    end
end

local function next(self, songs)
    if self.bgm then
        self.bgm:stop()
        self.bgm = nil
    end
    self:play(songs)
end

local function play(self, songs)
    if self.bgm then
        if not self.bgm:isPlaying() then
            self.bgm:play()
        end
    else
        local song = songs[1]
        -- add audio source
        self.bgm = au.newSource("assets/music/" .. song, "stream")

        -- start playing song
        au.play(self.bgm)
    end
end
local function up(self)
    self.bgm:setVolume(self.bgm:getVolume() + .1)
end
local function down(self)
    self.bgm:setVolume(self.bgm:getVolume() - .1)
end
return { next = next, up = up, isMuted = isMuted, down = down, toggle = toggle, mute = mute, play = play }
