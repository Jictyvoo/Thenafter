unpack = unpack or table.unpack
local ParserBNF = {}

ParserBNF.__index = ParserBNF

function ParserBNF:new(filename)
    local this = {
        filename = filename,
        empty = {""},
        lexemes = {},
        tokens = {},
        info = {},
        productions = {}
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
                lineCounter = lineCounter + 1
                self.tokens[lineCounter] = {}
            end
        else
            table.insert(self.tokens[lineCounter], self.lexemes[index])
        end
    end
    if #self.tokens[lineCounter] == 0 then self.tokens[lineCounter] = nil end
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

function ParserBNF:extractLines()
    for line, tokenLine in pairs(self.tokens) do
        if tokenLine[1]:match("[\", \'].*[\", \']") then
            if tokenLine[2] == "=" then
                local name = string.sub(tokenLine[1], 2, #tokenLine[1] - 1)
                self.info[name] = #tokenLine > 3 and {} or tokenLine[3]
                if #tokenLine > 3 then
                    for index = 3, #tokenLine do
                        table.insert(self.info[name], tokenLine[index])
                    end
                end
            else
                error("When setting a info, a equal(=) symbol is needed")
            end
        elseif tokenLine[1]:match("<.*>") then
            assert(tokenLine[2] == "::=", string.format("The symbol \"::=\" is needed to indicate a production. \"%s\" are given", tokenLine[2]))
            self.productions[tokenLine[1]] = {}
            local production = {}
            for index = 3, #tokenLine do
                if tokenLine[index] == "|" then
                    if #production > 0 then
                        table.insert(self.productions[tokenLine[1]], production)
                        production = {}
                    end
                else
                    table.insert(production, tokenLine[index])
                end
            end
            if #production > 0 then table.insert(self.productions[tokenLine[1]], production) end
            if tokenLine[#tokenLine] == "|" then table.insert(self.productions[tokenLine[1]], self.empty) end
        end
    end
    if not self.info["Start Symbol"] then error("Start Symbol not set") end
end

function ParserBNF:parse()
    for line in io.lines(self.filename) do
        line = self:removeComment(line:gsub(string.format("%s%s%s", string.char(239), string.char(187), string.char(191)), ""))
        if line then
            self:getTokens(line)
        end
    end
    self:lexemesInTokenLines()
    self:extractLines()
end

return ParserBNF
