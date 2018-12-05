local ls=love.system

local state={}

function state.openUrl(x)
  if x=='üü' then
  elseif type(x)=='string' then
    ls.openURL(x)
  else state.load=x end
end


return state
