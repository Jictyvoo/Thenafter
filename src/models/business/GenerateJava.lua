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

function GenerateJava:writeGet(name)
    self.file:write(string.format([[
    public HashMap<String, HashSet<String>> get%s(){
        return this.%s;
    }

]], name, string.lower(name)))
end

function GenerateJava:writeHash(name, toWrite)
    self.file:write(string.format("\t\tthis.%s = new HashMap<>();\n", name))
    for index, value in pairs(toWrite) do
        self.file:write(string.format("\t\tthis.%s.put(\"%s\", %s", name, index:gsub("[<,>]", ""), "new HashSet<>(Arrays.asList("))
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
end

function GenerateJava:write(productions)
    self.file:write("import java.util.HashSet;\nimport java.util.Arrays;\nimport java.util.ArrayList;\nimport java.util.HashMap;\nimport java.util.List;\n\n")
    self.file:write([[
public class FirstFollow{
]])
    for index, value in pairs(self.info) do
        self.file:write(string.format("\tpublic final String %s;\n", index:gsub("%s+", "")))
    end
    self.file:write("\tprivate HashMap<String, HashSet<String>> first;\n\tprivate HashMap<String, HashSet<String>> follow;\n\tprivate static FirstFollow instance;\n\n")
    self.file:write([[
    private FirstFollow(){
]])
    for index, value in pairs(self.info) do
        self.file:write(string.format("\t\tthis.%s = \"%s\";\n", index:gsub("%s+", ""), value:gsub("\'", "")))
    end
    self:writeHash("first", self.first)
    self:writeHash("follow", self.follow)
    self.file:write("\t}\n\n")
    if productions then
        self.file:write([[
    public HashMap<String, List<List<String>>> getProductions(){
        HashMap<String, List<List<String>>> productions = new HashMap<>();
]])
        for index, value in pairs(productions) do
            self.file:write(string.format("\t\tproductions.put(\"%s\", new ArrayList<>(Arrays.asList(", index))
            local firstList = true
            for _, production in pairs(value) do
                if firstList then
                    self.file:write("new ArrayList<>(Arrays.asList(")
                    firstList = false
                else
                    self.file:write(", new ArrayList<>(Arrays.asList(")
                end
                local first = true
                for __, derivated in pairs(production) do
                    if first then
                        self.file:write(string.format("\"%s\"", derivated))
                        first = false
                    else
                        self.file:write(string.format(", \"%s\"", derivated))
                    end
                end
                self.file:write("))")
            end
            self.file:write(")));\n")
        end
        self.file:write("\t\treturn productions;\n\t}\n\n")
    end
    self:writeGet("First")
    self:writeGet("Follow")
    self.file:write([[
    public static FirstFollow getInstance(){
        if(instance == null){
            instance = new FirstFollow();
        }
        return instance;
    }
]])
    self.file:write("}\n")
    self.file:close()
end

return GenerateJava
