---@class Object
Object = {}
Object.__index = Object
function Object:init()
end

---@return Object
function Object:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end

---@param T Object
---@return boolean
function Object:is(T)
    local mt = getmetatable(self)
    while mt do
        if mt == T then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

function Object:__call(...)
    local obj = setmetatable({}, self)
    obj:init(...)
    return obj
end

function Object:emptyFunction()
end

function Object:nop()
end

return Object
