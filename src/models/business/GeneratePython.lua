local GeneratePython = {}

GeneratePython.__index = GeneratePython

function GeneratePython:new(filePointer, info, first, follow)
    assert(filePointer, "A file pointer is needed")
    local this = {
        file = filePointer,
        info = info or {generatedBy = "Jictyvoo"},
        first = first or {},
        follow = follow or {}
    }

    return setmetatable(this, GeneratePython)
end

function GeneratePython:writeTuple(name, content)
    self.file:write(string.format("\t\tself.%s = {\n", name))
    local first = true
    for index, value in pairs(content) do
        if first then first = false else self.file:write(",\n") end
        self.file:write(string.format("\t\t\t\"%s\" : (", index))
        local firstTerminal = true
        for terminal, _ in pairs(value) do
            if firstTerminal then firstTerminal = false else self.file:write(", ") end
            self.file:write(string.format("\"%s\"", terminal:gsub("\'", "")))
        end
        self.file:write(")")
    end
    self.file:write("\n\t\t}\n")
end

function GeneratePython:writeProduction(productions)
    self.file:write("\t\tself.__production = {")
    local firstKey = true
    for index, value in pairs(productions) do
        self.file:write(string.format("%s\n\t\t\t\"%s\": (", firstKey and "" or ",", index))
        firstKey = false; local firstList = true
        for _, production in pairs(value) do
            if firstList then self.file:write("("); firstList = false
            else self.file:write(", (")
            end
            local first = true
            for __, derivated in pairs(production) do
                if first then self.file:write(string.format("\"%s\"", derivated)); first = false
                else self.file:write(string.format(", \"%s\"", derivated))
                end
            end
            self.file:write(")")
        end
        self.file:write(")")
    end
    self.file:write("\n\t\t}\n\n")
end

function GeneratePython:writeGetters(attribute, encapsulation)
    self.file:write(string.format("\tdef get_%s(self):\n\t\t\treturn %s%s\n\n", attribute, encapsulation, attribute))
end

function GeneratePython:write(productions)
    self.file:write("class FirstFollow:\n\tdef __init__(self):\n")
    for index, value in pairs(self.info) do
        self.file:write(string.format("\t\tself.%s = \"%s\"\n", index:gsub("%s+", ""), value:gsub("\'", "")))
    end
    self:writeTuple("__first", self.first)
    self:writeTuple("__follow", self.follow)
    if productions then
        self:writeProduction(productions)
        self:writeGetters("productions", "__")
    end
    self:writeGetters("first", "__"); self:writeGetters("follow", "__")
end

return GeneratePython
