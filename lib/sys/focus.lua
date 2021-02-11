local lyra = require "lib.lyra"

local Music = require "lib.sys.Music"

return function(f)
    if not f then
        if not lyra.paused then
            lyra.unpause = true
            lyra.paused = true
        end
        if not Music:isMuted() then
            Music:mute()
            lyra.unmute = true
        end
    else
        if lyra.unmute then
            Music:play()
            lyra.unmute = false
        end
        if lyra.unpause then
            lyra.paused = false
            lyra.unpause = false
        end
    end
end