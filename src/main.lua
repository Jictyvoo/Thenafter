local flags = {}
local filename = ""
arg[0] = nil; arg[-1] = nil

local function isFlag(argument)
    if string.sub(argument, 1, 2) == "--" then
        return true
    end
    return false
end

local previousFlag = nil
for index, argument in pairs(arg) do
    if previousFlag then
        flags[previousFlag] = argument
    elseif isFlag(argument) then
        previousFlag = argument
    else
        filename = argument
    end
end

local parserBNF = require "controllers.ParserBNF":new(filename)
parserBNF:parse()
