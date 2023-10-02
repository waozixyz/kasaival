local function init(self, ...)
    self.items = {}
    self.cx = 0
    self.gh = 600
    self.gw = 3000
    self.startx = -100
    self.scenes = {}
    self.currentScene = 1
    self.next = nil
    self.kill_count = {}

    for _, v in ipairs({...}) do
        table.insert(self.items, v)
    end
    self.visible_items = self.items
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
    if not self.kill_count[item] then
        self.kill_count[item] = 0
    end
    return self.kill_count[item]
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
