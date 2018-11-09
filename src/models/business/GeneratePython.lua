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

function GeneratePython:write()
end

return GeneratePython
