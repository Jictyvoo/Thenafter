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
    self.file:write("import java.util.HashSet;\nimport java.util.Arrays;\nimport java.util.HashMap;\n\n")
    self.file:write([[
public class FirstFollow{
]])
    for index, value in pairs(self.info) do
        self.file:write(string.format("\tpublic final String %s;\n", index:gsub("%s+", "")))
    end
    self.file:write("\tprivate HashMap<String, HashSet<String>> first;\n\n")
    self.file:write([[
    public FirstFollow(){
]])
    for index, value in pairs(self.info) do
        self.file:write(string.format("\t\tthis.%s = \"%s\";\n", index:gsub("%s+", ""), value:gsub("\'", "")))
    end
    self.file:write("\t\tthis.first = new HashMap<>();\n")
    for index, value in pairs(self.first) do
        self.file:write(string.format("\t\tthis.first.put(\"%s\", %s", index, "new HashSet<>(Arrays.asList("))
        local first = true
        for production, _ in pairs(value) do
            production = production:gsub("\'", "")
            if first then
                self.file:write(string.format("\"%s\"", production))
                first = false
            else
                self.file:write(string.format(", \"%s\"", production))
            end
        end
        self.file:write(")));\n")
    end
    self.file:write("\t}\n\n")
    self.file:write([[
    public HashMap<String, HashSet<String>> getFirst(){
        return this.first;
    }
]])
    self.file:write("}\n")
    self.file:close()
end

return GenerateJava
