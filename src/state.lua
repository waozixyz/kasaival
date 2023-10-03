local function init(self, ...)
    self.cx = 0
    self.gh = 600
    self.gw = 0
    self.scenes = {}
    self.currentScene = 1
    self.next = nil
    self.killCount = {}

    for _, v in ipairs({...}) do
        table.insert(self.items, v)
    end
    return self
end

local function getCurrentQuests(self)
    if self.scenes[self.currentScene] and self.scenes[self.currentScene].quests then
        return self.scenes[self.currentScene].quests
    else return {} end
end

local function getCurrentQuestHint(self)
    if self.scenes[self.currentScene] and self.scenes[self.currentScene].questHint then
        return self.scenes[self.currentScene].questHint
    end
end

local function getKillCount(self, item)
    if not self.killCount[item] then
        self.killCount[item] = 0
    end
    return self.killCount[item]
end

local function getItems(self, name)
    local rtn = {}
    for _, v in ipairs(self.items) do
        if v.type == name then
            table.insert(rtn, v)
        end
    end
    return rtn
end

return {
    init = init,
    getCurrentQuests = getCurrentQuests,
    getCurrentQuestHint = getCurrentQuestHint,
    getKillCount = getKillCount,
    getItems = getItems,
}
