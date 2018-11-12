local FirstGenerator = {}

FirstGenerator.__index = FirstGenerator

function FirstGenerator:new(productions)
    assert(productions, "Need a productions table to make first table")
    return setmetatable({
        productions = productions,
        first = {}
    }, FirstGenerator)
end

function FirstGenerator:concatenateTables(main, secondary)
    for index, value in pairs(secondary) do
        main[index] = true
    end
    return main
end

function FirstGenerator:of(productionName)
    if self.first[productionName] then return self.first[productionName] end
    self.first[productionName] = {}
    for index, production in pairs(self.productions[productionName]) do
        if production[1]:match("<.*>") then
            self:concatenateTables(self.first[productionName], self:of(production[1]))
        else
            local name = #production[1] > 0 and production[1] or "''"
            self.first[productionName][name] = true
        end
    end
    return self.first[productionName]
end

function FirstGenerator:start()
    for index, value in pairs(self.productions) do
        self:of(index)
    end
end

return FirstGenerator
