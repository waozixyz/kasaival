local au = love.audio
local ma = love.math

local function mute(self)
    if self.bgm then
        return (self.bgm):pause()
    end
end
local function play(self, songs)
    if self.bgm then
        if not self.bgm:isPlaying() then
            self.bgm:play()
        end
    else
        local song = songs[ma.random(1, #songs)]
        while song == self.songTitle do
            song = songs[ma.random(1, #songs)]
        end
        self.songTitle = song
        self.bgm = au.newSource(self.dir .. song.author .. "/" .. song.title .. song.ext, "stream")
        au.play(self.bgm)
    end
end
return { dir = "assets/music/", mute = mute, play = play }
