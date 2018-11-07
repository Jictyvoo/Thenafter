local ParserBNF = {}

ParserBNF.__index = ParserBNF

function ParserBNF:new(filename)
    local this = {
        filename = filename
    }

    return setmetatable(this, ParserBNF)
end

function ParserBNF:removeComment(line)
    
end

function ParserBNF:parse()
    for line in io.lines(self.filename) do
        print("file")
    end
end

return ParserBNF