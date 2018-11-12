local flags = {}
local singleFlags = {["--p"] = false}
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
        previousFlag = nil
    elseif isFlag(argument) then
        if singleFlags[argument] ~= nil then
            singleFlags[argument] = true
        else
            previousFlag = argument
        end
    else
        filename = argument
    end
end

local parserBNF = require "controllers.ParserBNF":new(filename)
parserBNF:parse()
local firstGenerator = require "controllers.FirstGenerator":new(parserBNF.productions)
firstGenerator:start()

local function writeFile(extension)
    local generators = {java = "GenerateJava", py = "GeneratePython", lua = "GenerateLua"}
    assert(generators[extension], string.format("Extension gived \"%s\" isn't valid", extension))
    local file = io.open(string.format("%s.%s", filename, extension), "w")
    local generator = require("models.business." .. generators[extension]):new(file, parserBNF.info, firstGenerator.first, parserBNF.follow)
    generator:write(singleFlags["--p"] and parserBNF.productions)
end

for flag, argument in pairs(flags) do
    if flag == "--l" then
        writeFile(argument)
    end
end

if not flags["--l"] then writeFile("lua") end
