local ParserBNF = {}

ParserBNF.__index = ParserBNF

function ParserBNF:new(filename)
    local this = {
        filename = filename,
        lexemes = {},
        tokens = {},
        info = {}
    }

    return setmetatable(this, ParserBNF)
end

function ParserBNF:removeComment(line)
    local newLine = line
    local previousIndex = 1
    local index = string.find(line, "!.*$", 1)
    local final = false
    repeat
        if index then
            if string.sub(line, index - 1, index - 1) == "'" then
                previousIndex = index
                index = string.find(line, "!.*$", previousIndex + 1)
            else
                final = true
            end
        else
            final = true
        end
    until final
    newLine = index and string.sub(line, 1, index - 1) or line
    if #newLine > 1 then
        if #newLine:gsub("%s+", "") > 0 then
            return newLine
        end
    end
    return nil
end

function ParserBNF:lexemesInTokenLines()
    local lineCounter = 1
    self.tokens[lineCounter] = {}
    for index = 1, #self.lexemes do
        if self.lexemes[index] == "$" then
            if "|" ~= self.lexemes[index + 1] then
                print(lineCounter, unpack(self.tokens[lineCounter]))
                lineCounter = lineCounter + 1
                self.tokens[lineCounter] = {}
            end
        else
            table.insert(self.tokens[lineCounter], self.lexemes[index])
        end
    end
end

function ParserBNF:getTokens(line)
    local openRule = false
    local openString = false
    local lexeme = ""
    for character in line:gmatch(".") do
        if character == "\"" or character == "\'" or openString then
            if openString and character == openString then
                table.insert(self.lexemes, lexeme .. character)
                openString = false; lexeme = ""
            elseif not openString then
                openString = character
                lexeme = lexeme .. character
            else
                lexeme = lexeme .. character
            end
        elseif character == "<" or openRule then
            if openRule and character == ">" then
                table.insert(self.lexemes, lexeme .. character)
                openRule = false; lexeme = ""
            elseif not openRule then openRule = true; lexeme = lexeme .. character
            else lexeme = lexeme .. character
            end
        elseif character ~= " " then
            lexeme = lexeme .. character
        elseif #lexeme > 0 then
            table.insert(self.lexemes, lexeme)
            lexeme = ""
        end
    end
    if #lexeme > 0 then
        table.insert(self.lexemes, lexeme)
        lexeme = ""
    end
    table.insert(self.lexemes, "$")
end

function ParserBNF:parse()
    for line in io.lines(self.filename) do
        line = self:removeComment(line:gsub(string.format("%s%s%s", string.char(239), string.char(187), string.char(191)), ""))
        if line then
            self:getTokens(line)
        end
    end
    self:lexemesInTokenLines()
end

return ParserBNF
