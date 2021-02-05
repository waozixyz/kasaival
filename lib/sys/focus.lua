local Music = require "lib.sys.Music"

return function(game, f)
    if not f then
        if not game.paused then
            game.unpause = true
            game.paused = true
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
            game.paused = false
            game.unpause = false
        end
    end
end