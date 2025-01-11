local Utils = {}

 function Utils.generateUniqueId()
    local template = "xxxxxxxx-xxxx-xxxx-yxxx-xxxxxxxxxxxx"
    local uniqueId = string.gsub(template, "[xy]", function (c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
    return uniqueId
end

return Utils
