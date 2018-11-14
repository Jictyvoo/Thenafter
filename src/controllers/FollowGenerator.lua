local FollowGenerator = {}

FollowGenerator.__index = FollowGenerator

function FollowGenerator:new(productions, first)
    assert(productions, "Need a productions table to make follow table")
    return setmetatable({
        productions = productions,
        producers = {},
        first = first,
        follow = {}
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

function FollowGenerator:of(production)
    if self.follow[production] then return self.follow[production] end
    self.follow[production] = {}
    
end

function FollowGenerator:start(startSymbol)
    self:productedBy()
    self.follow[startSymbol] = {"$"}
    for index, value in pairs(self.producers) do
        for production, _ in pairs(value) do
            self:of(production)
        end
    end
end

return FollowGenerator
