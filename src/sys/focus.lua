local state = require "state"

local Music = require "sys.Music"

return function(f)
    if not f then
        if not state.paused then
            state.unpause = true
            state.paused = true
        end
        if not Music:isMuted() then
            Music:mute()
            state.unmute = true
        end
    else
        if state.unmute then
            Music:play()
            state.unmute = false
        end
        if state.unpause then
            state.paused = false
            state.unpause = false
        end
    end
end