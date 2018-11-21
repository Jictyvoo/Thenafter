local FollowGenerator = {}

FollowGenerator.__index = FollowGenerator

function FollowGenerator:new(productions, first)
    assert(productions, "Need a productions table to make follow table")
    return setmetatable({
        productions = productions,
        producers = {},
        first = first,
        follow = {},
        concatenateList = {},
        startSymbol = nil
    }, FollowGenerator)
end

--[[Method to identify who produce every production in list--]]
function FollowGenerator:productedBy()
    for key, value in pairs(self.productions) do
        for _, allProductions in pairs(value) do
            for __, production in pairs(allProductions) do
                if production:match("<.*>") then
                    if not self.producers[production] then self.producers[production] = {} end
                    self.producers[production][key] = true
                end
            end
        end
    end
end

function FollowGenerator:concatenateTables(main, secondary)
    if secondary then
        for index, value in pairs(secondary) do
            if index ~= "''" then
                main[index] = true
            end
        end
    end
    return main
end

function FollowGenerator:giveMeFirst(from)
    if not from then return nil end
    if from:match("<.*>") then
        return self.first[from]
    end
    local newFirst = {}; newFirst[from] = true
    return newFirst
end

function FollowGenerator:toConcatenate(main, secondary)
    if not self.concatenateList[main] then self.concatenateList[main] = {} end
    table.insert(self.concatenateList[main], secondary)
end

function FollowGenerator:of(production, hasToo)
    if self.follow[production] then return self.follow[production] end
    self.follow[production] = self:concatenateTables({}, hasToo)
    if not self.producers[production] then
        if production == self.startSymbol then
            return self.follow[production]
        else
            error(string.format("Production %s is not used, please fix it", production))
        end
    end
    for key, _ in pairs(self.producers[production]) do
        for count = 1, #self.productions[key] do
            for index = 1, #self.productions[key][count] do
                local value = self.productions[key][count][index]
                if value == production then
                    if index == #self.productions[key][count] then
                        self:toConcatenate(self.follow[production], self:of(key))
                    elseif index > 1 then
                        self:toConcatenate(self.follow[production], self.first[key])
                        if self.first[key]["''"] then
                            self:toConcatenate(self.follow[production], self:of(key))
                        end
                    else
                        local newFirst = self:giveMeFirst(self.productions[key][count][index + 1])
                        self:toConcatenate(self.follow[production], newFirst)
                    end
                    index = #self.productions[key][count] + 1
                end
            end
        end
    end
    return self.follow[production]
end

function FollowGenerator:concatenateAll()
    for main, _ in pairs(self.concatenateList) do
        for index, value in pairs(self.concatenateList[main]) do
            self:concatenateTables(main, value)
        end
    end
end

function FollowGenerator:start(startSymbol)
    self.startSymbol = startSymbol
    self:productedBy()
    self:of(startSymbol, {["'$'"] = true})
    for production, value in pairs(self.productions) do
        self:of(production)
    end
    self:concatenateAll(); self:concatenateAll()
end

return FollowGenerator
