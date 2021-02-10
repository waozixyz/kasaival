local lyra = require "lib.lyra"

local Music = require "lib.sys.Music"

return function(game, f)
    if not f then
        if not lyra.paused then
            game.unpause = true
            lyra.paused = true
        end
        if not Music:isMuted() then
            Music:mute()
            game.unmute = true
        end
    else
        if game.unmute then
            Music:play()
            game.unmute = false
        end
        if game.unpause then
            lyra.paused = false
            game.unpause = false
        end
    end
end