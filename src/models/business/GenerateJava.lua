local GenerateJava = {}

GenerateJava.__index = GenerateJava

function GenerateJava:new(filePointer)
    local this = {
        file = filePointer
    }

    return setmetatable(this, GenerateJava)
end

function GenerateJava:write()
    
end

return GenerateJava
