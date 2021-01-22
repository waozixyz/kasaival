local fi = love.filesystem
local gr = love.graphics

local function checkFiles(self, saves)
    local rtn = {}

    for i, sav in ipairs(saves) do
        if (#sav < 2) then
            if sav.file then
                rtn[i] = sav
            else
                table.remove(rtn, i)
            end
        end
    end
    return rtn
end
local function getFiles(self)
    local rtn = {}
    if not fi.getInfo("saves") then fi.createDirectory("saves") end
    local files = fi.getDirectoryItems("saves")
    for _, file in ipairs(files) do
        local id = file:gsub("save", "")
        id = id:gsub(".png", "")
        id = tonumber(id)
        if (rtn[id] == nil) then rtn[id] = {} end
        local s = rtn[id]
        if string.find(file, ".png") then
            s["img"] = gr.newImage("saves/" .. file)
        else
            s["file"] = file
        end
        rtn[id] = s
    end
    return self:checkFiles(rtn)
end
local function nextSave(self)
    return (self.saveName .. (#self:getFiles() + 1))
end
return {checkFiles = checkFiles, getFiles = getFiles, nextSave = nextSave, saveName = "saves/save"}
