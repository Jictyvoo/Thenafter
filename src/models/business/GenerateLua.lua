local GenerateLua = {}

GenerateLua.__index = GenerateLua

function GenerateLua:new(filePointer, info, first, follow)
    assert(filePointer, "A file pointer is needed")
    local this = {
        file = filePointer,
        info = info or {generatedBy = "Jictyvoo"},
        first = first or {},
        follow = follow or {}
    }

    return setmetatable(this, GenerateLua)
end

function GenerateLua:writeTable(table, tabCharacter, first)
	self.file:write("{\n")
    for key, value in pairs(table) do
        if type(key) == "number" then key = string.format("[%d]", key)
        elseif key:match("<.*>") then key = string.format("[\"%s\"]", key)
        elseif key:match("\'.*\'") then key = string.format("[%s]", key:gsub("'", "\""))
        else key = key:gsub("%s+", "") end
		if type(value) == "table" then
            if type(key) == "string" then
				self.file:write(tabCharacter .. "\t" .. key:gsub("%..*", "") .. " = ")
			end
			self:writeTable(value, tabCharacter .. "\t")
		else
			local writeValue = value
			if type(value) == "string" then
				writeValue = string.format("\"%s\"", value)
            end
			self.file:write(tabCharacter .. "\t" .. string.format("%s = %s,\n", tostring(key), tostring(writeValue)))
		end
	end
	self.file:write(tabCharacter .. (first and "}\n" or "},\n"))
end

function GenerateLua:write(productions)
    self.file:write("return ")
    self:writeTable({productions = productions, info = self.info, first = self.first, follow = self.follow}, "", true)
    self.file:close()
end

return GenerateLua
