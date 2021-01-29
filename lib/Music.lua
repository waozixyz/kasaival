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
        local newSong
        while newSong == self.title do
            newSong = ma.random(1, #songs)
        end
        newSong = songs[newSong]
        -- add audio source
        self.bgm = au.newSource(self.dir .. newSong.author .. "/" .. newSong.title .. "." .. newSong.ext, "stream")

        -- add current song title and author to state
        self.title = newSong.title
        self.author = newSong.author

        -- start playing song
        au.play(self.bgm)
    end
end
return { song = {}, dir = "assets/music/", mute = mute, play = play }
