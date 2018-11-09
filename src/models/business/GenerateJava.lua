local GenerateJava = {}

GenerateJava.__index = GenerateJava

function GenerateJava:new(filePointer, info, first, follow)
    assert(filePointer, "A file pointer is needed")
    local this = {
        file = filePointer,
        info = info or {generatedBy = "Jictyvoo"},
        first = first or {},
        follow = follow or {}
    }

    return setmetatable(this, GenerateJava)
end

function GenerateJava:write()
    self.file:write([[
public class FirstFollow{
]])
    for index, value in pairs(self.info) do
        self.file:write(string.format("\tpublic final String %s;\n", index:gsub("%s+", "")))
    end
    self.file:write([[
    public FirstFollow(){
]])
    for index, value in pairs(self.info) do
        self.file:write(string.format("\t\tthis.%s = \"%s\";\n", index:gsub("%s+", ""), value))
    end
    self.file:write("\t}\n")
    self.file:write("}\n")
    self.file:close()
end

return GenerateJava
