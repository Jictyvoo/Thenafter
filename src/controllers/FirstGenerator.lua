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
        if index ~= "''" then
            main[index] = true
        end
    end
    return main
end

function FirstGenerator:of(productionName)
    if self.first[productionName] then return self.first[productionName] end
    self.first[productionName] = {}
    assert(self.productions[productionName], string.format("Production \"%s\" not defined", productionName))
    
    for index, production in pairs(self.productions[productionName]) do
        local count = 1
        repeat
            if production[count]:match("<.*>") then
                local productionOf = self:of(production[count])
                self:concatenateTables(self.first[productionName], productionOf)
                if not productionOf["''"] then count = #production + 1 end
            else
                local name = #production[count] > 0 and production[count] or "''"
                self.first[productionName][name] = true
                count = #production + 1
            end
            count = count + 1
        until count >= #production
    end
    return self.first[productionName]
end

function FirstGenerator:start()
    for index, value in pairs(self.productions) do
        self:of(index)
    end
end

return FirstGenerator
