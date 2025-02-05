local Object = require("engine.object")
local EffectUIImagesPath = require("effects.effectsConfig")
local Effect = Object:extend()
Effect.__index = Effect

function Effect:new(params)
    local instance = setmetatable({}, self)
    instance:init(params)
    return instance
end

function Effect:init(params)
    if not params.applyFunc or not params.removeFunc or not params.actionFunc then
        error("Effect must have an applyFunc, removeFunc and actionFunc")
    end

    if not params.UIName then
        error("Effect must have a UIName")
    end

    if EffectUIImagesPath[params.UIName] == nil then
        error("Effect UIName '" .. params.UIName .. "' not found in effectsConfig.lua")
    end

    self.name = params.name or "Unnamed Effect"

    -- UI
    self.UIName = params.UIName
    self.UIIcon = love.graphics.newImage(EffectUIImagesPath[self.UIName])

    -- Propriétés optionnelles
    self.duration = params.duration or 5
    self.remainingTime = self.duration
    self.applyFunc = params.applyFunc -- Fonction à appeler pour appliquer l'effet
    self.removeFunc = params.removeFunc -- Fonction à appeler pour retirer l'effets
    self.actionFunc = params.actionFunc -- Fonction à appeler à chaque tick
    self.tickRate = params.tickRate or 1
    self.lastTick = 0

    -- Memo
    self.memo = nil
end

function Effect:apply(entity)
    self.applyFunc(entity, self)
end

function Effect:remove(entity)
    self.removeFunc(entity, self)
end

function Effect:update(dt, entity)
    self.remainingTime = self.remainingTime - dt
    if self.remainingTime <= 0 then
        self:remove(entity)
        return false -- Signale que l'effet doit être supprimé
    end

    -- Appliquer les effets de type "tick" (ex: poison)
    if self.tickRate and love.timer.getTime() - self.lastTick >= self.tickRate then
        self.lastTick = love.timer.getTime()
        self.actionFunc(entity, self)
    end

    return true
end

return Effect
