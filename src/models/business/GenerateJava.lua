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

function GenerateJava:write(productions)
    self.file:write("import java.util.HashSet;\nimport java.util.Arrays;\nimport java.util.ArrayList;\nimport java.util.HashMap;\nimport java.util.List;\n\n")
    self.file:write([[
public class FirstFollow{
]])
    for index, value in pairs(self.info) do
        self.file:write(string.format("\tpublic final String %s;\n", index:gsub("%s+", "")))
    end
    self.file:write("\tprivate HashMap<String, HashSet<String>> first;\n\tprivate static FirstFollow instance;\n\n")
    self.file:write([[
    private FirstFollow(){
]])
    for index, value in pairs(self.info) do
        self.file:write(string.format("\t\tthis.%s = \"%s\";\n", index:gsub("%s+", ""), value:gsub("\'", "")))
    end
    self.file:write("\t\tthis.first = new HashMap<>();\n")
    for index, value in pairs(self.first) do
        self.file:write(string.format("\t\tthis.first.put(\"%s\", %s", index:gsub("[<,>]", ""), "new HashSet<>(Arrays.asList("))
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
    self.file:write([[
    public HashMap<String, HashSet<String>> getFirst(){
        return this.first;
    }

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
