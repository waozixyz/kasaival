local au = love.audio
local ma = love.math

local function mute(self)
    if self.bgm then
        return (self.bgm):pause()
    end
end
local function play(self)
    if self.bgm then
        if not (self.bgm):isPlaying() then
            return (self.bgm):play()
        end
    else
        local title = self.songTitle
        while (title == self.songTitle) do
            self.songTitle = self.songs[ma.random(#self.songs)]
        end
        self.bgm = au.newSource((self.dir .. self.songTitle .. self.ext), "stream")
        return au.play(self.bgm)
    end
end
return {
    dir = "assets/music/",
    ext = ".ogg",
    mute = mute,
    play = play,
    songAuthor = "TeknoAXE",
    songs = {"Running_On_Air", "Robot_Disco_Dance", "Supersonic", "Caught_in_the_Drift"}
}
