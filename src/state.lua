local function init(self, ...)
    self.cx = 0
    self.gh = 600
    self.gw = 0
    self.scenes = {}
    self.currentScene = 1
    self.next = nil
    self.killCount = {}
    self.nextScene = false
    self.nextStage = false

    for _, v in ipairs({...}) do
        table.insert(self.items, v)
    end
    return self
end

local function completeQuest(self, id)
    self:getCurrentQuests()[id] = nil
    if #self:getCurrentQuests() <= 0 then
        self.nextScene = true
    end
end

local function updateQuests(self, dt)
    for i, q in ipairs(self:getCurrentQuests()) do
        if q.questType == "time" then
            q.amount = q.amount - dt
            if q.amount <= 0 then
                completeQuest(self, i)
            end
        elseif q.questType == "kill" then
            if self.killCount[q.entityType] and self.killCount[q.entityType] >= q.amount then
                completeQuest(self, i)
            end
        end
        if q.fail and q:fail(self) then
            self.questFailed = true
        end
    end
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

local function getKillCount(self, entityType)
    if not self.killCount[entityType] then
        self.killCount[entityType] = 0
    end
    return self.killCount[entityType]
end

local function getItems(self, entityType)
    local rtn = {}
    for _, v in ipairs(self.items) do
        if v.entityType == entityType then
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
    updateQuests = updateQuests
}
