local BulletObject = require("weapons.BulletObject")

---@class FireBall : BulletObject
local FireBall = BulletObject:extend()

function FireBall:new(params)
    ---@type FireBall
    local self = setmetatable({}, FireBall)

    params = params or {}
    params.name = "fireBall"
    params.imageRatio = params.imageRatio or 1
    params.imagePath = "sprites/weapons/fireStaff/fireball.png"

    BulletObject.init(self, params)
    return self
end

function FireBall:ajusteRotation()
    return self.direction
end

return FireBall
