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

function GeneratePython:write(productions)
    self.file:write("class FirstFollow:\n\tdef __init__(self):\n")
    for index, value in pairs(self.info) do
        self.file:write(string.format("\t\tself.%s = \"%s\"\n", index:gsub("%s+", ""), value:gsub("\'", "")))
    end
    self:writeTuple("first", self.first)
    self:writeTuple("follow", self.follow)
end

return GeneratePython
