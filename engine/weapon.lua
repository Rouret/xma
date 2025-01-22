local Object = require("engine.object")
local State = require("player.state")

Weapon = Object:extend()
Weapon.__index = Weapon

function Weapon:new(params)
    local instance = setmetatable({}, self)
    instance:init(params)
    return instance
end

function Weapon:init(params)
    params = params or {}

    if not params.skills then
        error("Skills parameter is required")
    end

    if #params.skills == 0 then
        error("Weapon must have 3 skills")
    end

    if not params.image then
        error("Sprite parameter is required")
    end

    -- General
    self.name = params.name or "Unnamed Weapon"
    self.status = "idle"

    -- Draw options
    self.imageRatio = params.imageRatio or 1

    -- Sprite
    self.sprite = love.graphics.newImage(params.image)
    local spriteWidth, spriteHeight = self.sprite:getDimensions()
    self.spriteWidth = spriteWidth
    self.spriteHeight = spriteHeight

    -- Skills
    self.skills = params.skills or {}

    return self
end

function Weapon:update(dt)
    error("update method not implemented")
end

-- Draw the gun
function Weapon:draw()
    -- Check if weapon is in hand or back
    if State.isWeaponEquipped(self.name) then
        self:drawInHand(State.x, State.y)
    else
        self:drawInBack()
    end
end

-- Draw gun in hand
function Weapon:drawInHand(x, y)
    self:defaultDrawInHand(x, y)
end

-- Draw gun in hand
function Weapon:defaultDrawInHand(x, y)
    local rotation = State.getAngleToMouse() - math.pi / 2
    love.graphics.draw(self.sprite, x, y, rotation, self.imageRatio, self.imageRatio, 0, 0)
end

-- Draw gun in the back
function Weapon:drawInBack()
end

return Weapon
